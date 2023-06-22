"""

Singleton to hold benchmark configuration fields.
They are initialised to default values below.
"""

import os

RunAOT = True
MeasureMem = False
MeasurePerf = False
BenchRoot = os.environ['PWD']
