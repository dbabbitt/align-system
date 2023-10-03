import csv
import json
from typing import List
from collections import defaultdict

"""
This file reads a dataset csv file with user treatment responses
and outputs a list of API compatible messages to the kickoff scenario
probe (which patient to treat first)

The CSV also includes data on which treatment is applied to each
patient but that information is not currently used for kickoff scenario
"""

# All data is a response to the following scenario & probe
SCENARIO_ID = 'kickoff-demo-scenario-1'
PROBE_ID    = 'kickoff-demo-probe-1'

# kickoff demo probe uses the following mapping
kickoff_probe_map = {
    'Casualty A': 'choice1',
    'Casualty B': 'choice2',
    'Casualty D': 'choice3',
    'Casualty E': 'choice4',
    'Casualty F': 'choice5',
}

def make_response_and_alignment_msg(user_responses: List[dict]) -> dict:
    # Probe is "which patient to select first"?
    # So we select the first patient in this user's
    # response list as the choice
    first_patient = user_responses[0]

    # User id is same for input responses
    user_id = user_responses[0]['UserId']

    patient = first_patient['PatientTreated']
    choice = kickoff_probe_map[patient]
    
    return {
        'user_id': user_id,
        'response': {
            # Kickoff demo scenario id is 'scenario1'
            'scenario_id': SCENARIO_ID,
            # Kickoff demo probe id is 'probe1'
            'probe_id': PROBE_ID,
            # Selection
            'choice': choice,
            'justification': ''
        },
        'alignment': {
            'alignment_source': [
                {
                    'scenario_id': SCENARIO_ID,
                    'probes': [PROBE_ID],
                }
            ],
            # Alignment target from kickoff demo
            'alignment_target_id': 'kdma-alignment-target-1',
            'score': 0, # alignment score not provided in dataset
            # KDMA values are provided in dataset
            'kdma_values': [
                { 'kdma': 'mission', 'value': first_patient['Mission'] },
                { 'kdma': 'denial',  'value': first_patient['Denial']  },
            ]
        }
    }


def read_user_responses(filename) -> List[List[dict]]:
    """
    The CSV has multiple rows per user, aggregate them into 
    separate lists per user while reading them in
    """
    user_responses = defaultdict(list)
    with open(filename) as f:
        reader = csv.DictReader(f)
        for row in reader:
            user_responses[row['UserId']].append(row)

    return list(user_responses.values())



# Read CSV data
user_responses = read_user_responses('ITM_synthetic_data_V1.csv') 
print(f'Got responses from {len(user_responses)} users')

# Convert to message format
print('Converting to message format...')
messages = []
for user_response in user_responses:
    messages.append(make_response_and_alignment_msg(user_response))

# Write messages to file
outfile_name = 'ITM_synthetic_data_patient_selection_messages_V1.json'
print(f"Saving response messages to '{outfile_name}'...")
with open(outfile_name, 'w') as f:
    json.dump({'messages': messages}, f, indent=4)