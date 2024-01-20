#!/usr/bin/env python3

import argparse as ag
import os
import sys
import glob
import subprocess as sp
import re
import tempfile
import shutil
import dataclasses
from dataclasses import dataclass

@dataclass
class MarianTrainConfig:
    marian_dir: str
    model: str
    model_type: str
    vocab1: str
    vocab2: str
    dim_vocab1: int
    dim_vocab2: int
    dim_emb: int
    epochs: int


def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)

def main():
    parser = ag.ArgumentParser()
    parser.add_argument('-t', '--train-sets',
                        type=ag.FileType('r', encoding='utf-8'), nargs=2, required=True)
    parser.add_argument('-i', '--input', type=ag.FileType('r', encoding='utf-8'), required=True)
    parser.add_argument('-m', '--model', required=True)
    parser.add_argument('-v', '--vocabs', nargs=2, required=True)
    parser.add_argument('--dim-vocabs', nargs=2, type=int, required=False)
    parser.add_argument('--dim-emb', type=int, required=False)
    parser.add_argument('-e', '--epochs', type=int, required=True)
    parser.add_argument('--type', required=True)
    parser.add_argument('--marian-dir', required=True)
    parser.add_argument('--output-costs', type=ag.FileType('w', encoding='utf-8'))
    parser.add_argument('--output-transl', type=ag.FileType('w', encoding='utf-8'))

    args = parser.parse_args()

    [sfile, tfile] = args.train_sets
    [vocab1, vocab2] = args.vocabs
    [dvocab1, dvocab2] = args.dim_vocabs if args.dim_vocabs is not None else [None, None]
    config = MarianTrainConfig(args.marian_dir, args.model, args.type, vocab1,
                               vocab2, dvocab1, dvocab1, args.dim_emb, args.epochs)
    eprint(config)
    costs_and_translations = iterate_over_inputs(config, sfile, tfile, args.input)
    output_costs_and_translations(costs_and_translations, args.output_costs, args.output_transl)


def training_file_generator(source, target):
    begin_sentences = True
    contains_sentences = False
    for sline, tline in zip(source, target):
        if begin_sentences:
            sfile = tempfile.NamedTemporaryFile(mode='w', encoding='utf-8', delete=False)
            tfile = tempfile.NamedTemporaryFile(mode='w', encoding='utf-8', delete=False)
            eprint(f"Created temp files for training data: {sfile.name}, {tfile.name}")
            begin_sentences = False
            contains_sentences = False

        if sline != "\n" or tline != "\n":
            eprint(sline.rstrip())
            eprint(tline.rstrip())
            sfile.write(sline)
            tfile.write(tline)
            contains_sentences = True
        else:
            sfile.close()
            tfile.close()
            yield (contains_sentences, sfile, tfile)
            begin_sentences = True

    # The last non-empty set of sentences can not be delimited with an empty line
    if contains_sentences:
        sfile.close()
        tfile.close()
        yield (contains_sentences, sfile, tfile)

def iterate_over_inputs(config, source, target, inputs):
    all_costs_and_translations = []
    try:
        for input_line, (contains_sentences, sfile, tfile) in zip(inputs, training_file_generator(source, target)):
            if contains_sentences:
                costs_and_translations = run_marian(sfile.name, tfile.name, input_line, config)
            else:
                eprint("No context provided, skipping training")
                translations = translate_marian(input_line, config)
                costs_and_translations = ([], translations)
            all_costs_and_translations.append(costs_and_translations)
            os.remove(sfile.name)
            os.remove(tfile.name)
    finally:
        for f in [sfile, tfile]:
            if f is not None and os.path.exists(f.name):
                if not f.closed:
                    f.close()
                os.remove(f.name)
                eprint(f"ERROR: Needed cleanup for {f.name}")
    return all_costs_and_translations

def run_marian(sfile, tfile, input_line, config):
    c = config
    temp_model_path = create_temp_model_copy(c.model)
    new_config = dataclasses.replace(c, model=temp_model_path)
    costs = train_marian(sfile, tfile, new_config)
    for path in glob.glob(f"{temp_model_path}*"):
        eprint(f"Removing model file: {path}")
        os.remove(path)
    translations = translate_marian(input_line, config)
    return (costs, translations)

def create_temp_model_copy(model):
    fd, path = tempfile.mkstemp(suffix='.npz')
    eprint(f"Created temp file for model: {path}")
    os.close(fd)
    shutil.copyfile(model, path)
    return path

def train_marian(sfile, tfile, config):
    c = config

    args = [f"{c.marian_dir}/marian", '-m', c.model, '--disp-freq', '1', '--optimizer', 'sgd', '--type', c.model_type, '-v',
            c.vocab1, '-v', c.vocab2, '--after-epochs', str(c.epochs), '--mini-batch', '1', '-t', sfile, tfile]
    if c.dim_emb is not None:
        args += ['--dim-emb', str(c.dim_emb)]
    if c.dim_vocab1 is not None and c.dim_vocab2 is not None:
        args += ['--dim-vocabs', str(c.dim_vocab1), str(c.dim_vocab2)]
    process = sp.run(args, capture_output=True, text=True)

    eprint("STDOUT:")
    eprint(process.stdout)
    eprint("STDERR:")
    eprint(process.stderr)
    costs = extract_costs(process.stderr)
    eprint("COSTS:")
    eprint(costs)
    return costs

def extract_costs(output_log):
    p = re.compile('Ep\..* Cost ([-e0-9.]+) .*: Time')
    costs = []
    for line in output_log.splitlines():
        m = p.search(line)
        if m is not None:
            costs.append(m.group(1))
    return costs

def translate_marian(input_line, config):
    c = config

    args = [f"{c.marian_dir}/marian-decoder", '-m', c.model,
            '--type', c.model_type, '-v', c.vocab1, '-v', c.vocab2]
    if c.dim_emb is not None:
        args += ['--dim-emb', str(c.dim_emb)]
    if c.dim_vocab1 is not None and c.dim_vocab2 is not None:
        args += ['--dim-vocabs', str(c.dim_vocab1), str(c.dim_vocab2)]
    process = sp.run(args, input=input_line, capture_output=True, text=True)

    eprint(f"Translate input: {input_line}")
    eprint("STDOUT:")
    eprint(process.stdout)
    eprint("STDERR:")
    eprint(process.stderr)
    translations = process.stdout.splitlines()
    eprint(translations)
    return translations

def output_costs_and_translations(costs_and_translations, output_costs, output_transl):
    eprint("COSTS AND TRANSLATIONS:")
    eprint(costs_and_translations)

    if output_costs is not None:
        all_costs = [cost for costs, _ in costs_and_translations for cost in costs]
        output_costs.writelines(map(lambda c: c + '\n', all_costs))
    if output_transl is not None:
        all_translations = [translation for _, translations in costs_and_translations for translation in translations]
        output_transl.writelines(map(lambda t: t + '\n', all_translations))


if __name__ == "__main__":
    main()
