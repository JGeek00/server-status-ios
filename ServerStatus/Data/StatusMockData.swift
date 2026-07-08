import Foundation

let statusMockData = """
    [
      {
        "cpu": {
          "model": "Intel(R) N100",
          "utilisation": 0.0050000000000000044,
          "temperature": [
            55,
            105
          ],
          "cpuCores": [
            {
              "frequencies": {
                "now": 700,
                "min": 700,
                "base": 800,
                "max": 3400
              }
            },
            {
              "frequencies": {
                "now": 700,
                "min": 700,
                "base": 800,
                "max": 3400
              }
            },
            {
              "frequencies": {
                "now": 700,
                "min": 700,
                "base": 800,
                "max": 3400
              }
            },
            {
              "frequencies": {
                "now": 700,
                "min": 700,
                "base": 800,
                "max": 3400
              }
            }
          ],
          "count": 4,
          "cache": 6144,
          "cores": 4
        },
        "memory": {
          "total": 16533422,
          "available": 13798158,
          "cached": 6590710,
          "swap_total": 4294963,
          "swap_available": 4294963,
          "processes": 220
        },
        "storage": [
          {
            "name": "Home",
            "icon": "folder",
            "total": 511392781107.2,
            "available": 447323279360
          }
        ],
        "network": {
          "interface": "enp1s0",
          "speed": 1000,
          "rx": 3359324347,
          "tx": 20296797412
        },
        "host": {
          "uptime": 1040164.13,
          "os": "Ubuntu 22.04.4 LTS",
          "hostname": "server",
          "app_memory": "13488",
          "loadavg": [
            0.1,
            0.06,
            0.05
          ]
        }
      },
      {
        "cpu": {
          "model": "Intel(R) N100",
          "utilisation": 0.0050000000000000044,
          "temperature": [
            56,
            105
          ],
          "cpuCores": [
            {
              "frequencies": {
                "now": 700,
                "min": 700,
                "base": 800,
                "max": 3400
              }
            },
            {
              "frequencies": {
                "now": 700,
                "min": 700,
                "base": 800,
                "max": 3400
              }
            },
            {
              "frequencies": {
                "now": 700,
                "min": 700,
                "base": 800,
                "max": 3400
              }
            },
            {
              "frequencies": {
                "now": 700,
                "min": 700,
                "base": 800,
                "max": 3400
              }
            }
          ],
          "count": 4,
          "cache": 6144,
          "cores": 4
        },
        "memory": {
          "total": 16533422,
          "available": 13796868,
          "cached": 6590714,
          "swap_total": 4294963,
          "swap_available": 4294963,
          "processes": 220
        },
        "storage": [
          {
            "name": "Home",
            "icon": "folder",
            "total": 511392781107.2,
            "available": 447323275264
          }
        ],
        "network": {
          "interface": "enp1s0",
          "speed": 1000,
          "rx": 3359328965,
          "tx": 20296805443
        },
        "host": {
          "uptime": 1040165.66,
          "os": "Ubuntu 22.04.4 LTS",
          "hostname": "server",
          "app_memory": "13488",
          "loadavg": [
            0.1,
            0.06,
            0.05
          ]
        }
      },
      {
        "cpu": {
          "model": "Intel(R) N100",
          "utilisation": 0.03500000000000003,
          "temperature": [
            56,
            105
          ],
          "cpuCores": [
            {
              "frequencies": {
                "now": 700,
                "min": 700,
                "base": 800,
                "max": 3400
              }
            },
            {
              "frequencies": {
                "now": 700,
                "min": 700,
                "base": 800,
                "max": 3400
              }
            },
            {
              "frequencies": {
                "now": 700,
                "min": 700,
                "base": 800,
                "max": 3400
              }
            },
            {
              "frequencies": {
                "now": 700,
                "min": 700,
                "base": 800,
                "max": 3400
              }
            }
          ],
          "count": 4,
          "cache": 6144,
          "cores": 4
        },
        "memory": {
          "total": 16533422,
          "available": 13798597,
          "cached": 6590718,
          "swap_total": 4294963,
          "swap_available": 4294963,
          "processes": 220
        },
        "storage": [
          {
            "name": "Home",
            "icon": "folder",
            "total": 511392781107.2,
            "available": 447323271168
          }
        ],
        "network": {
          "interface": "enp1s0",
          "speed": 1000,
          "rx": 3359334732,
          "tx": 20296816559
        },
        "host": {
          "uptime": 1040167.13,
          "os": "Ubuntu 22.04.4 LTS",
          "hostname": "server",
          "app_memory": "13488",
          "loadavg": [
            0.09,
            0.06,
            0.05
          ]
        }
      },
      {
        "cpu": {
          "model": "Intel(R) N100",
          "utilisation": 0.0,
          "temperature": [
            55,
            105
          ],
          "cpuCores": [
            {
              "frequencies": {
                "now": 700,
                "min": 700,
                "base": 800,
                "max": 3400
              }
            },
            {
              "frequencies": {
                "now": 700,
                "min": 700,
                "base": 800,
                "max": 3400
              }
            },
            {
              "frequencies": {
                "now": 700,
                "min": 700,
                "base": 800,
                "max": 3400
              }
            },
            {
              "frequencies": {
                "now": 700,
                "min": 700,
                "base": 800,
                "max": 3400
              }
            }
          ],
          "count": 4,
          "cache": 6144,
          "cores": 4
        },
        "memory": {
          "total": 16533422,
          "available": 13800002,
          "cached": 6590718,
          "swap_total": 4294963,
          "swap_available": 4294963,
          "processes": 220
        },
        "storage": [
          {
            "name": "Home",
            "icon": "folder",
            "total": 511392781107.2,
            "available": 447323271168
          }
        ],
        "network": {
          "interface": "enp1s0",
          "speed": 1000,
          "rx": 3359335279,
          "tx": 20296817874
        },
        "host": {
          "uptime": 1040168.64,
          "os": "Ubuntu 22.04.4 LTS",
          "hostname": "server",
          "app_memory": "13488",
          "loadavg": [
            0.09,
            0.06,
            0.05
          ]
        }
      },
      {
        "cpu": {
          "model": "Intel(R) N100",
          "utilisation": 0.005025125628140725,
          "temperature": [
            55,
            105
          ],
          "cpuCores": [
            {
              "frequencies": {
                "now": 700,
                "min": 700,
                "base": 800,
                "max": 3400
              }
            },
            {
              "frequencies": {
                "now": 700,
                "min": 700,
                "base": 800,
                "max": 3400
              }
            },
            {
              "frequencies": {
                "now": 700,
                "min": 700,
                "base": 800,
                "max": 3400
              }
            },
            {
              "frequencies": {
                "now": 700,
                "min": 700,
                "base": 800,
                "max": 3400
              }
            }
          ],
          "count": 4,
          "cache": 6144,
          "cores": 4
        },
        "memory": {
          "total": 16533422,
          "available": 13793575,
          "cached": 6590718,
          "swap_total": 4294963,
          "swap_available": 4294963,
          "processes": 220
        },
        "storage": [
          {
            "name": "Home",
            "icon": "folder",
            "total": 511392781107.2,
            "available": 447323271168
          }
        ],
        "network": {
          "interface": "enp1s0",
          "speed": 1000,
          "rx": 3359335706,
          "tx": 20296819283
        },
        "host": {
          "uptime": 1040170.14,
          "os": "Ubuntu 22.04.4 LTS",
          "hostname": "server",
          "app_memory": "13488",
          "loadavg": [
            0.09,
            0.06,
            0.05
          ]
        }
      }
    ]
"""
