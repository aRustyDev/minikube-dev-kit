#!/usr/bin/env python3
"""
Testing memphis->mageai->CockroachDB.
-  psycopg3
-  memphis
"""

# Memphis imports
from memphis import Memphis, Headers
from memphis.types import Retention, Storage
from memphis.message import Message
import asyncio

# Transform imports
import json
import sys
from datetime import datetime
import pandas as pd
from .transforms.azure.audit import AuditTransform as ual
from .transforms.azure.adfs import AdfsTransform as adfs
from .transforms.azure.msi import MsiTransform as msi
from .transforms.azure.refresh_token import RefreshTokenTransform as rt
from .transforms.azure.service_principal import ServicePrincipalTransform as sp

# CockroachDB imports
import logging
import uuid
from argparse import ArgumentParser, RawTextHelpFormatter

import psycopg
from psycopg.errors import SerializationFailure, Error
from psycopg.rows import namedtuple_row


async def connect_to_memphis(host, username, password):
    try:
        memphis = Memphis()
        await memphis.connect(host=host, username=username, password=password)
        return memphis
    except (MemphisError, MemphisConnectError) as e:
        print(e)

def connect_to_cockroachdb(host, username, password):
    try:
        # Attempt to connect to cluster with connection string provided to
        # script. By default, this script uses the value saved to the
        # DATABASE_URL environment variable.
        # For information on supported connection string formats, see
        # https://www.cockroachlabs.com/docs/stable/connect-to-the-database.html.
        db_url = opt.dsn
        conn = psycopg.connect(db_url,
                               application_name='$ docs_simplecrud_psycopg3',
                               row_factory=namedtuple_row)
        return conn
    except Exception as e:
        logging.fatal('database connection failed')
        logging.fatal(e)
        return

def determine_transform(transform):
    match transform:
        case 'ual':
            optimus = ual()
        case 'msi':
            optimus = msi()
        case 'rt':
            optimus = rt()
        case 'sp':
            optimus = sp()
        case 'adfs':
            optimus = adfs
        case _: # TODO: add error type
            return Error
    return optimus

# TODO: Abstract to take connection and record type to decide which table to create/insert into
def create_ual_table(conn, schema):
    with conn.cursor() as cur:
        cur.execute(schema)
        logging.debug('create_table(): status message: %s',
                      cur.statusmessage)
    return

def create_ual_record(conn, msg_data):
    rid = uuid.uuid4()
    with conn.cursor() as cur:
        cur.execute('SELECT id FROM ual')
        rows = cur.fetchall()
        ids = [row[0] for row in rows]
        return rid

async def main():
    opt = parse_cmdline()
    logging.basicConfig(level=logging.DEBUG if opt.verbose else logging.INFO)

    try:
        # TODO: leverage opt to determine which transform to use
        # TODO: alternatively, use a ENV var to determine which transform to use
        this = determine_transform(someInput)

        # Initialize connections (Memphis, CockroachDB)
        # TODO: remove hardcoded creds
        consumer = await connect_to_memphis('memphis.datapipe.svc.cluster.local', 'abc_consumer', 'Go-P@55word').consumer(station_name='ual', consumer_name='mageai-transform-abc', consumer_group='mageai-transforms')
        crdb = connect_to_cockroachdb('cockroachdb-public.datapipe.svc.cluster.local', 'cockroach', 'cockroach')
        create_ual_table(crdb, this.table_schema)

        messages: list[Message] = await consumer.fetch() # Type-hint the return here for LSP integration

        for consumed_message in messages:
            this.load(consumed_message.get_data())

            # Do something with the message data
            try:
                # TODO: Do transformations here
                # ============ BEGIN TEMPORARY CODE ============
                if data: # Ensure it's not an empty line
                    try:
                        df_jsonl = pd.json_normalize(this.transform())
                        df_jsonl.columns = ['json_element']
                        df_jsonl['json_element'].apply(json.loads)
                        df_final = pd.json_normalize(df_jsonl['json_element'].apply(json.loads))
                    except json.JSONDecodeError:
                        print(f'Invalid JSON input: {this.data}', file=sys.stderr)
                # ============ END TEMPORARY CODE ============
                create_ual_record(crdb, df_final)
            except ValueError as ve:
                # Below, we print the error and continue on so this example is easy to
                # run (and run, and run...).  In real code you should handle this error
                # and any others thrown by the database interaction.
                logging.debug('run_transaction(conn, op) failed: %s', ve)
                pass
            except psycopg.Error as e:
                logging.debug('got error: %s', e)
                raise e
            await consumed_message.ack()

    # TODO: handle cockroachdb errors
    except (MemphisError, MemphisConnectError) as e:
        print(e)

    finally:
        await memphis.close()

if __name__ == '__main__':
    asyncio.run(main())
