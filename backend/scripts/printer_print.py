import sys
from escpos.printer import Usb
import json
from datetime import datetime
import pytz

if len(sys.argv) >= 4:
    vendor_id = int(sys.argv[1], 16)
    product_id = int(sys.argv[2], 16)
else:
    print("Usage: python printer.py vendor_id product_id orderJson")
    sys.exit(1)

# p = Usb(0x1fc9, 0x2016)
p = Usb(vendor_id, product_id)

order = json.loads(sys.argv[3])


def print_order(order):
    p.set(align='center', font='b', height=2, width=2)

    # now = datetime.now()
    # parse date from json iso format
    now = datetime.strptime(order['date'], '%Y-%m-%dT%H:%M:%S.%fZ')
    italian_timezone = pytz.timezone('Europe/Rome')
    now_italian = now.replace(tzinfo=pytz.utc).astimezone(italian_timezone)
    date_time = now_italian.strftime("%H:%M:%S")
    p.text(f'Tavolo: {order["table"]["number"]}\n')
    p.text(f'Ora: {date_time}\n\n')

    amount = 0

    for item in order['dishes']:
        dish_str = f'{item["quantity"]}x {item["dish"]["name"]}\n'
        eur_str = f'EUR {item["dish"]["price"] / 100:.2f}\n'.replace('.', ',')

        p.set(align='left', font='b', height=3, width=3)
        p.text(dish_str)

        amount += item['quantity'] * item['dish']['price']

        if item['notes']:
            p.set(align='left', font='a', height=2, width=2)
            p.text(f'Note: {item["notes"]}\n')
        p.text('\n')

    p.set(align='right', font='b', height=2, width=2)
    # amount is in cents, use 2 decimal places
    p.text(f'Totale: EUR {amount / 100:.2f}\n\n'.replace('.', ','))

    p.cut()


print_order(order)

p.close()
