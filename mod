{
	"Defaults": {
		"Application": "RJA_Azure_Deploy",
		"SubApplication": "RJA_Azure_Flow",
		"Host": "cirrocumulus",
		"RunAs": "ctmserver",
		"ControlmServer": "cirrocumulus",
		"CreatedBy": "Reggie"
	},

  "RJA_AzureFlow": {
    "Type": "Folder",
    "Variables": [
      {
        "\\PARM1": "%%tempmax"
      },
      {
        "\\PARM2": "%%tempmin"
      },
      {
        "\\PARM3": "%%desc"
      },
      {
        "\\PARM4": "%%name"
      }
    ],
    "OrderMethod": "Manual",
    "ActiveRetentionPolicy": "CleanEndedOK",
    "SiteStandard": "RJA_Azure", 
    "When": {
      "RuleBasedCalendars": {
        "Included": [
          "EVERYDAY"
        ],
        "EVERYDAY": {
          "Type": "Calendar:RuleBased",
          "When": {
            "WeekDays": [
              "NONE"
            ]
          }
        }
      }
    },
    "RJA_GET_Data": {
      "Type": "Job:Command",
      "FileName": "requests.py",
      "RunAsDummy": true,   
      "FilePath": "/mnt/nfs/home/rjacobs/Python/",
      "Command": "curl -X GET \"https://api.openweathermap.org/data/2.5/weather?q=Farnham&units=metric&appid=15fcec5856e017f9feae9fb5a5940855\" > $HOME/Weather.json",
      "When": {
			"Schedule": "Never"
		},
      "IfBase:Folder:CompletionStatus_0": {
        "Type": "If:CompletionStatus",
        "CompletionStatus": "NOTOK",
        "Action:SetToOK_0": {
          "Type": "Action:SetToOK"
        }
      },
      "CaptureOutput_1": {
        "Type": "Action:CaptureOutput",
        "Capture": "UpToEndOfLine",
        "Search": "main",
        "VariableName": "\\main"
      },
      "CaptureOutput_2": {
        "Type": "Action:CaptureOutput",
        "Capture": "UpToEndOfLine",
        "Search": "Clouds",
        "VariableName": "Clouds"
      },
      "eventsToAdd": {
        "Type": "AddEvents",
        "Events": [
          {
            "Event": "RJA_API-TO-RJA_Extract_Data"
          }
        ]
      }
    },
    "RJA_Extract_Data": {
      "Type": "Job:Command",
      "RunAsDummy": true,
      "Command": "cd $HOME/&& cat Weather.json | jq -r '.name,.main,.weather'",
      "When": {
			"Schedule": "Never"
		},
      "IfBase:Folder:CompletionStatus_0": {
        "Type": "If:CompletionStatus",
        "CompletionStatus": "NOTOK",
        "Action:SetToOK_0": {
          "Type": "Action:SetToOK"
        }
      },
      "CaptureOutput_1": {
        "Type": "Action:CaptureOutput",
        "Capture": "UpToEndOfLine",
        "Search": "\"temp_min\":",
        "VariableName": "\\tempmin"
      },
      "CaptureOutput_2": {
        "Type": "Action:CaptureOutput",
        "Capture": "UpToEndOfLine",
        "Search": "\"temp_max\":",
        "VariableName": "\\tempmax"
      },
      "CaptureOutput_3": {
        "Type": "Action:CaptureOutput",
        "Capture": "UpToEndOfLine",
        "Search": "\"main\":",
        "VariableName": "\\main"
      },
      "CaptureOutput_4": {
        "Type": "Action:CaptureOutput",
        "Capture": "UpToEndOfLine",
        "Search": "\"description\":",
        "VariableName": "\\desc"
      },
      "CaptureOutput_5": {
        "Type": "Action:CaptureOutput",
        "Capture": "UpToEndOfLine",
        "Search": "\"name\":",
        "VariableName": "\\name"
      },
      "eventsToWaitFor": {
        "Type": "WaitForEvents",
        "Events": [
          {
            "Event": "RJA_API-TO-RJA_Extract_Data"
          }
        ]
      },
      "eventsToAdd": {
        "Type": "AddEvents",
        "Events": [
          {
            "Event": "RJA_Extract_Data-TO-RJA_Forecast"
          }
        ]
      },
      "eventsToDelete": {
        "Type": "DeleteEvents",
        "Events": [
          {
            "Event": "RJA_API-TO-RJA_Extract_Data"
          }
        ]
      }
    },
    "RJA_Process_Data": {
      "Type": "Job:EmbeddedScript",
      "Script": "#!/bin/bash\\n# My first weather personalisation script\\n\\ncurl -X GET \"https://api.openweathermap.org/data/2.5/weather?q=Farnham&units=metric&appid=15fcec5856e017f9feae9fb5a5940855\" > $HOME/Weather.json\\n\\n# jq . $HOME/Weather.json\\n\\ntemp_max=\"`jq . $HOME/Weather.json | sed 's/^ *//g' | sed 's/\\\"//g' | sed 's/,//g' |awk '/temp_max/ { print $2 }' | sed 's/\\..*//'`\"\\n\\necho \"$temp_max\"\\n\\nif [ $temp_max -gt 19 ]\\nthen\\n   echo \"*---------------------*\\n    echo \"Remember your hat !!!\"\\n   echo \"*---------------------*\\nelse\\n    echo \"Please do not forget your jacket.\"\\nfi\\n",
      "RunAsDummy": true,
      "Priority": "Very Low",
      "FileName": "scrippie.sh",
      "FilePath": "/mnt/nfs/home/rjacobs",
      "When": {
			"Schedule": "Never"
		},
      "IfBase:Folder:CompletionStatus_0": {
        "Type": "If:CompletionStatus",
        "CompletionStatus": "NOTOK",
        "Action:SetToOK_0": {
          "Type": "Action:SetToOK"
        }
      },
      "eventsToWaitFor": {
        "Type": "WaitForEvents",
        "Events": [
          {
            "Event": "RJA_Extract_Data-TO-RJA_Forecast"
          }
        ]
      },
      "eventsToDelete": {
        "Type": "DeleteEvents",
        "Events": [
          {
            "Event": "RJA_Extract_Data-TO-RJA_Forecast"
          }
        ]
      }
    }
  }
}
