import sys
from escpos.printer import Usb

if len(sys.argv) >= 4:
    vendor_id = int(sys.argv[1], 16)
    product_id = int(sys.argv[2], 16)
else:
    print("Usage: python printer.py vendor_id product_id text")
    sys.exit(1)

# p = Usb(0x1fc9, 0x2016)
p = Usb(vendor_id, product_id)

text = sys.argv[3]

p.text(text)
p.cut()

p.close()
