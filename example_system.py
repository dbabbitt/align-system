import argparse
import json
import sys
import random


def main():
    parser = argparse.ArgumentParser(
        description="Example (random) system")

    parser.add_argument('probe_filepath',
                        type=str,
                        help="File path to input probe JSON")
    parser.add_argument("--handshake-filepath",
                        type=str,
                        required=True,
                        help="File path to input handshake JSON")
    parser.add_argument("--print-details",
                        action='store_true',
                        default=False,
                        help="Print out background / patient / probe "
                             "information in human readable form")

    run_example_system(**vars(parser.parse_args()))

    return 0


def run_example_system(probe_filepath,
                       handshake_filepath,
                       print_details=False):
    with open(handshake_filepath) as f:
        handshake_data = json.load(f)

    if print_details:
        print("::SITUATION::", file=sys.stderr)
        print(handshake_data['state']['situation']['unstructured'],
              file=sys.stderr)
        print(file=sys.stderr)

    with open(probe_filepath) as f:
        probe_data = json.load(f)

    if print_details:
        print("::PATIENT SUMMARY::", file=sys.stderr)
        for patient in probe_data.get('patients', ()):
            print("[{}]  {}".format(patient['id'], patient['unstructured']),
                  file=sys.stderr)
        print(file=sys.stderr)

    decisions = list(enumerate(probe_data.get('decisions', ())))
    if print_details:
        print("::POSSIBLE DECISIONS::", file=sys.stderr)
        for i, decision in decisions:
            print("[{}]  {} (Patient {})".format(
                i + 1, decision['action'], decision['target']),
                  file=sys.stderr)
        print(file=sys.stderr)

    selected_decision = random.choice(decisions)
    decision_id, decision = selected_decision
    if print_details:
        print("::DECISION::", file=sys.stderr)
        print("[{}]  {} (Patient {})".format(
                decision_id + 1, decision['action'], decision['target']),
              file=sys.stderr)
        print(file=sys.stderr)

    print(json.dumps(decision, indent=2))


if __name__ == "__main__":
    sys.exit(main())
