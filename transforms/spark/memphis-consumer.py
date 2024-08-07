from __future__ import annotations
import asyncio
from memphis import Memphis, MemphisError, MemphisConnectError, MemphisHeaderError

async def main():
    async def msg_handler(msgs, error, context):
        try:
            for msg in msgs:
                print('message: ', msg.get_data())
                await msg.ack()
                if error:
                    print(error)
        except (MemphisError, MemphisConnectError, MemphisHeaderError) as e:
            print(e)
            return

    try:
        memphis = Memphis()
        await memphis.connect(host='memphis.datapipe.svc.cluster.local', username='spark', password='Spark-P@55word', account_id=1)

        consumer = await memphis.consumer(station_name='ual', consumer_name='spark', consumer_group='transform')
        consumer.set_context({'key': 'value'})
        consumer.consume(msg_handler)
        # Keep your main thread alive so the consumer will keep receiving data
        await asyncio.Event().wait()

    except (MemphisError, MemphisConnectError) as e:
        print(e)

    finally:
        await memphis.close()

if __name__ == '__main__':
    asyncio.run(main())
