#!/usr/bin/python
from subprocess import check_output
import os

def get_pass(mailbox):
    path = os.path.join(
        os.environ['HOME'],
        '.password-store',
        '{}.gpg'.format(mailbox)
    )
    gpg = [
        'gpg2', '--batch', '--no-tty',
        '--use-agent', '-dq', path
    ]
    return check_output(gpg).strip()
