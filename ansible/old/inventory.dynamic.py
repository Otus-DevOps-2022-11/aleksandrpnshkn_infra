#!/usr/bin/python3

# Скрипт на основе https://habr.com/ru/post/704518/

import argparse
import json

# Example hosts store
store = {
    "app": {
        "metadatafromstore": {
            "ip": ['158.160.62.133'],
        }
    },
    "db": {
        "metadatafromstore": {
            "ip": ['130.193.51.107'],
        }
    },
}


def get_host_vars(host):
    data = {
        'ansible_host': host,
        'ansible_user': 'ubuntu',
    }
    if host in store:
        metadata = store[host].get('metadatafromstore', {}) or {}
        data['ansible_host'] = metadata['ip'][0]

    return data


def get_vars(host, pretty=False):
    """
    Function which return json data of host's variables.
    """
    return json.dumps({}, indent=pretty)


def get_list(pretty=False):
    """
    Function which return inventory data for hosts.
    Example contains all variants of groups. Syntax as yaml inventory but with '_meta' section.

    - 'hostvars' is all variables for hosts.
    - 'all' is default group which should be always created.
    - 'ungrouped' is testing group with hosts.
    """
    hostvars, ungrouped = {}, []

    for host in store:
        ungrouped.append(host)
        hostvars[host] = get_host_vars(host)

    data = {
        '_meta': {
          'hostvars': hostvars
        },
        'all': {
            'children': [
                'ungrouped'
            ]
        },
        'ungrouped': {
            'hosts': ungrouped
        }
    }
    return json.dumps(data, indent=pretty)


# Parse arguments.
# Ansible require two: '--list' and output of all data and '--host [hostname] for getting variables about one host'
parser = argparse.ArgumentParser()
parser.add_argument(
    "--list",
    action='store_true',
    help="Show JSON of all managed hosts"
)
parser.add_argument(
    "--host",
    action='store',
    help="Display vars related to the host"
)
args = parser.parse_args()

# Print output will be parsed via ansible as inventory (like a file).
if args.host:
    print(get_vars(args.host))
elif args.list:
    print(get_list())
else:
    raise ValueError("Expecting either --host $HOSTNAME or --list")
