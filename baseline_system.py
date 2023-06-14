import argparse
from dataclasses import dataclass
from typing import List
import sys
from enum import Enum

from swagger_client import ItmMvpApi
from swagger_client.configuration import Configuration
from swagger_client.api_client import ApiClient
from swagger_client.models import (
    Scenario,
    Environment,
    Patient,
    Probe,
    MedicalSupply,
)

from algorithms.llm_baseline import (
    LLMBaseline,
    prepare_prompt,
    prepare_prompt_instruct_gpt_j,
    select_first_mentioned_patient,
)

# Copy-paste from CACI's `itm_adm_scenario_runner.py` script; ideally
# we could just import this from their client module
@dataclass
class ADMKnowledge:
    """
    What the ADM keeps track of throughout the scenario.
    """
    # Scenario
    scenario_id: str = None
    scenario: Scenario = None

    # Info
    description: str = None
    environment: Environment = None

    # Patients
    patients: List[Patient] = None
    all_patient_ids: List[str] = None
    treated_patient_ids: List[str] = None
    treated_all_patients: bool = False

    # Probes
    current_probe: Probe = None
    explanation: str = None
    probes_received: List[Probe] = None
    probes_answered: int = 0

    # Supplies
    supplies: List[MedicalSupply] = None

    def check_treated_all_patients(self):
        return self.all_patient_ids.issubset(
            self.treated_patient_ids)

    def untreated_patients(self):
        return self.all_patient_ids - self.treated_patient_ids


# Copy-paste from CACI's `itm_scenario_runner.py` script; ideally
# we could just import this from their client module
class CommandOption(Enum):
    START = "start"
    PROBE = "probe"
    STATUS = "status"
    VITALS = "vitals"
    RESPOND = "respond"
    HEART_RATE = "heart rate"
    END = "end"


def main():
    parser = argparse.ArgumentParser(
        description="Simple LLM baseline system")

    parser.add_argument('-a', '--api_endpoint',
                        default="http://127.0.0.1:8080",
                        type=str,
                        help='Restful API endpoint for scenarios / probes '
                             '(default: "http://127.0.0.1:8080")')
    parser.add_argument('-u', '--username',
                        type=str,
                        default='ALIGN-ADM',
                        help='ADM Username (provided to TA3 API server, '
                             'default: "ALIGN-ADM")')
    parser.add_argument('-m', '--model',
                        type=str,
                        default="gpt-j",
                        help="LLM Baseline model to use")

    run_baseline_system(**vars(parser.parse_args()))

    return 0


def retrieve_scenario(client, username):
    return client.start_scenario(username)


def retrieve_probe(client, scenario_id):
    return client.get_probe(scenario_id)


def answer_probe(client, probe_id, patient_id, explanation):
    client.respond_to_probe(
        probe_id,
        patient_id,
        explanation=explanation)


def adm_knowledge_from_scenario(scenario):
    adm_knowledge: ADMKnowledge = ADMKnowledge()
    adm_knowledge.scenario_id = scenario.id
    adm_knowledge.patients = scenario.patients
    adm_knowledge.all_patient_ids =\
        {patient.id for patient in scenario.patients}
    adm_knowledge.treated_patient_ids = {}
    adm_knowledge.probes_received = []
    adm_knowledge.supplies = scenario.medical_supplies
    adm_knowledge.environment = scenario.environment
    adm_knowledge.description = scenario.description

    return adm_knowledge


def run_baseline_system(api_endpoint, username, model):
    _config = Configuration()
    _config.host = api_endpoint
    _api_client = ApiClient(configuration=_config)
    client = ItmMvpApi(api_client=_api_client)

    scenario = retrieve_scenario(client, username)
    adm_knowledge = adm_knowledge_from_scenario(scenario)

    # Break if we've treated all patients
    while not adm_knowledge.check_treated_all_patients():
        current_probe = retrieve_probe(client, scenario.id)
        adm_knowledge.probes_received.append(current_probe)

        llm_baseline = LLMBaseline(
            device="cuda", model_use=model, distributed=False)
        llm_baseline.load_model()

        if model == "instruct-gpt-j":
            prompt = prepare_prompt_instruct_gpt_j(scenario, current_probe)
        else:
            prompt = prepare_prompt(scenario, current_probe)

        print("* Prompt for ADM: {}".format(prompt))

        raw_response = llm_baseline.run_inference(prompt)
        print("* ADM Raw response: {}".format(raw_response))
        selected_patient_id = select_first_mentioned_patient(raw_response)

        if selected_patient_id is not None:
            print("* ADM Selected: '{}'".format(selected_patient_id))

        # Just pick first untreated patient if unable to parse patient
        # ID from model response
        if selected_patient_id is None:
            print("* Picking random patient ..")
            selected_patient_id = list(
                adm_knowledge.untreated_patients())[0].id
            print("** Selected: '{}'".format(selected_patient_id))

        print()
        answer_probe(client,
                     current_probe.id,
                     selected_patient_id,
                     explanation=raw_response)


if __name__ == "__main__":
    sys.exit(main())
