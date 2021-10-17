import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flagsmith/flagsmith.dart';
import 'package:flagsmith_core/flagsmith_core.dart';

import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:mockito/mockito.dart';

class Mocked extends Mock implements FlagsmithException {
  void genericError({Object? message}) {
    throw FlagsmithException(message);
  }

  void wrongFlagFormat({Object? message}) {
    throw FlagsmithFormatException(FormatException());
  }

  void apiException({Object? message}) {
    throw FlagsmithApiException(
        DioError(requestOptions: RequestOptions(path: 'path')));
  }

  void configException({Object? message}) {
    throw FlagsmithConfigException(Exception('missing config'));
  }
}

final apiKey = 'CoJErJUXmihfMDVwTzBff4_fake';
final seeds = [
  Flag.seed('my_feature', enabled: true),
  Flag.seed('enabled_feature', enabled: true),
  Flag.seed('enabled_value', enabled: true, value: '2.0.0')
];
const notImplmentedFeature = 'not_implemented_flag';
const myFeature = 'my_feature';
final fakeMallformedResponse = r'''[
    {
        "id": 48540,
        "feature": {
            "id": 9368,
            "name": "fake_disabled_feature",
            "created_date": "2021-05-24T08:38:29.203517Z",
            "description": "Fake Disabled feature",
            "initial_value": null,
            "default_enabled": false,
            "type": "STANDARD"
        },
        "feature_state_value": null,
        "enabled": false,
        "environment": 7822,
        "identity": null,
        "feature_segment": null,
    },
]''';
final fakeResponse = r'''[
    {
        "id": 48540,
        "feature": {
            "id": 9368,
            "name": "fake_disabled_feature",
            "created_date": "2021-05-24T08:38:29.203517Z",
            "description": "Fake Disabled feature",
            "initial_value": null,
            "default_enabled": false,
            "type": "STANDARD"
        },
        "feature_state_value": null,
        "enabled": false,
        "environment": 7822,
        "identity": null,
        "feature_segment": null
    },
    {
        "id": 48541,
        "feature": {
            "id": 9368,
            "name": "disabled_feature",
            "created_date": "2021-05-24T08:38:29.203517Z",
            "description": "Disabled feature",
            "initial_value": null,
            "default_enabled": false,
            "type": "STANDARD"
        },
        "feature_state_value": null,
        "enabled": false,
        "environment": 7822,
        "identity": null,
        "feature_segment": null
    },
    {
        "id": 48543,
        "feature": {
            "id": 9369,
            "name": "enabled_feature",
            "created_date": "2021-05-24T08:38:47.375641Z",
            "description": "Enabled test feature",
            "initial_value": null,
            "default_enabled": true,
            "type": "STANDARD"
        },
        "feature_state_value": null,
        "enabled": true,
        "environment": 7822,
        "identity": null,
        "feature_segment": null
    },
    {
        "id": 48545,
        "feature": {
            "id": 9370,
            "name": "min_version",
            "created_date": "2021-05-24T08:39:05.095219Z",
            "description": "test min version",
            "initial_value": "1.0.1",
            "default_enabled": true,
            "type": "STANDARD"
        },
        "feature_state_value": "2.0.0",
        "enabled": true,
        "environment": 7822,
        "identity": null,
        "feature_segment": null
    },
    {
        "id": 48547,
        "feature": {
            "id": 9371,
            "name": "my_feature",
            "created_date": "2021-05-24T08:39:24.938442Z",
            "description": "My feature",
            "initial_value": null,
            "default_enabled": false,
            "type": "STANDARD"
        },
        "feature_state_value": "my_feature_value",
        "enabled": true,
        "environment": 7822,
        "identity": null,
        "feature_segment": null
    },
    {
        "id": 48549,
        "feature": {
            "id": 9372,
            "name": "show_title_logo",
            "created_date": "2021-05-24T08:40:25.683907Z",
            "description": "Show logo in Navigation bar",
            "initial_value": null,
            "default_enabled": false,
            "type": "STANDARD"
        },
        "feature_state_value": null,
        "enabled": false,
        "environment": 7822,
        "identity": null,
        "feature_segment": null
    },
    {
        "id": 52786,
        "feature": {
            "id": 10101,
            "name": "max_version",
            "created_date": "2021-06-20T07:14:26.446931Z",
            "description": "Max version of package",
            "initial_value": "3.0.0",
            "default_enabled": false,
            "type": "STANDARD"
        },
        "feature_state_value": "3.0.0",
        "enabled": false,
        "environment": 7822,
        "identity": null,
        "feature_segment": null
    },
    
    {
        "id": 58,
        "feature": {
            "id": 24,
            "name": "try_it",
            "created_date": "2018-06-15T11:01:46.018370Z",
            "description": "Try it panels",
            "initial_value": null,
            "default_enabled": true,
            "type": "STANDARD"
        },
        "feature_state_value": null,
        "enabled": true,
        "environment": 23,
        "identity": null,
        "feature_segment": null
    },
    {
        "id": 5815,
        "feature": {
            "id": 1530,
            "name": "segment_operators",
            "created_date": "2019-10-07T16:25:47.073428Z",
            "description": "Determines what rules are shown when creating a segment",
            "initial_value": "[\n  {\n    \"value\": \"EQUAL\",\n    \"label\": \"Exactly Matches (=)\"\n  },\n  {\n    \"value\": \"NOT_EQUAL\",\n    \"label\": \"Does not match (!=)\"\n  },\n  {\n    \"value\": \"PERCENTAGE_SPLIT\",\n    \"label\": \"% Split\"\n  },\n  {\n    \"value\": \"GREATER_THAN\",\n    \"label\": \">\"\n  },\n  {\n    \"value\": \"GREATER_THAN_INCLUSIVE\",\n    \"label\": \">=\"\n  },\n  {\n    \"value\": \"LESS_THAN\",\n    \"label\": \"<\"\n  },\n  {\n    \"value\": \"LESS_THAN_INCLUSIVE\",\n    \"label\": \"<=\"\n  },\n  {\n    \"value\": \"CONTAINS\",\n    \"label\": \"Contains\"\n  },\n  {\n    \"value\": \"NOT_CONTAINS\",\n    \"label\": \"Does not contain\"\n  },\n  {\n    \"value\": \"REGEX\",\n    \"label\": \"Matches regex\"\n  }\n]",
            "default_enabled": false,
            "type": "STANDARD"
        },
        "feature_state_value": "[\n  {\n    \"value\": \"EQUAL\",\n    \"label\": \"Exactly Matches (=)\"\n  },\n  {\n    \"value\": \"NOT_EQUAL\",\n    \"label\": \"Does not match (!=)\"\n  },\n  {\n    \"value\": \"PERCENTAGE_SPLIT\",\n    \"label\": \"% Split\"\n  },\n  {\n    \"value\": \"GREATER_THAN\",\n    \"label\": \">\"\n  },\n  {\n    \"value\": \"GREATER_THAN_INCLUSIVE\",\n    \"label\": \">=\"\n  },\n  {\n    \"value\": \"LESS_THAN\",\n    \"label\": \"<\"\n  },\n  {\n    \"value\": \"LESS_THAN_INCLUSIVE\",\n    \"label\": \"<=\"\n  },\n  {\n    \"value\": \"CONTAINS\",\n    \"label\": \"Contains\"\n  },\n  {\n    \"value\": \"NOT_CONTAINS\",\n    \"label\": \"Does not contain\"\n  },\n  {\n    \"value\": \"REGEX\",\n    \"label\": \"Matches regex\"\n  }\n]",
        "enabled": true,
        "environment": 23,
        "identity": null,
        "feature_segment": null
    },
    {
        "id": 9209,
        "feature": {
            "id": 2201,
            "name": "demo_link_color",
            "created_date": "2020-01-29T14:55:06.097715Z",
            "description": "Colour of demo feature",
            "initial_value": "blue",
            "default_enabled": false,
            "type": "STANDARD"
        },
        "feature_state_value": "white2",
        "enabled": true,
        "environment": 23,
        "identity": null,
        "feature_segment": null
    },
    {
        "id": 11065,
        "feature": {
            "id": 2509,
            "name": "demo_feature",
            "created_date": "2020-03-07T17:30:47.410158Z",
            "description": "Shows a demo feature in the side navigation bar",
            "initial_value": null,
            "default_enabled": false,
            "type": "STANDARD"
        },
        "feature_state_value": null,
        "enabled": false,
        "environment": 23,
        "identity": null,
        "feature_segment": null
    },
    {
        "id": 12307,
        "feature": {
            "id": 2712,
            "name": "oauth_github",
            "created_date": "2020-03-28T21:04:37.376577Z",
            "description": "GitHub login key",
            "initial_value": "{\n  \"url\": \"https://github.com/login/oauth/authorize?scope=user&client_id=5d99dd45d6cdf4a4ac61&redirect_uri=https%3A%2F%2Fdev.bullet-train.io%2Foauth%2Fgithub\"\n}",
            "default_enabled": true,
            "type": "STANDARD"
        },
        "feature_state_value": "{\n  \"url\": \"https://github.com/login/oauth/authorize?scope=user&client_id=5d99dd45d6cdf4a4ac61&redirect_uri=https%3A%2F%2Fdev.bullet-train.io%2Foauth%2Fgithub\"\n}",
        "enabled": true,
        "environment": 23,
        "identity": null,
        "feature_segment": null
    },
    {
        "id": 12310,
        "feature": {
            "id": 2713,
            "name": "oauth_google",
            "created_date": "2020-03-28T21:04:51.557946Z",
            "description": "Google login key",
            "initial_value": "{\n \"clientId\":\"232959427810-br6ltnrgouktp0ngsbs04o14ueb9rch0.apps.googleusercontent.com\",\n \"apiKey\":\"AIzaSyCnHuN-y6BIEAM5vTISXaz3X9GpEPSxWjo\"\n}",
            "default_enabled": false,
            "type": "STANDARD"
        },
        "feature_state_value": "{\n \"clientId\":\"232959427810-br6ltnrgouktp0ngsbs04o14ueb9rch0.apps.googleusercontent.com\",\n \"apiKey\":\"AIzaSyCnHuN-y6BIEAM5vTISXaz3X9GpEPSxWjo\"\n}",
        "enabled": true,
        "environment": 23,
        "identity": null,
        "feature_segment": null
    },
    {
        "id": 12313,
        "feature": {
            "id": 2714,
            "name": "oauth_facebook",
            "created_date": "2020-03-28T21:05:00.766672Z",
            "description": "Soon TM",
            "initial_value": null,
            "default_enabled": false,
            "type": "STANDARD"
        },
        "feature_state_value": null,
        "enabled": true,
        "environment": 23,
        "identity": null,
        "feature_segment": null
    },
    {
        "id": 12316,
        "feature": {
            "id": 2715,
            "name": "oauth_microsoft",
            "created_date": "2020-03-28T21:05:13.100534Z",
            "description": "Soon TM",
            "initial_value": null,
            "default_enabled": false,
            "type": "STANDARD"
        },
        "feature_state_value": "",
        "enabled": true,
        "environment": 23,
        "identity": null,
        "feature_segment": null
    },
    {
        "id": 27322,
        "feature": {
            "id": 5538,
            "name": "plan_based_access",
            "created_date": "2020-11-04T10:50:21.174891Z",
            "description": "Controls rbac and 2f based on plans",
            "initial_value": null,
            "default_enabled": true,
            "type": "STANDARD"
        },
        "feature_state_value": null,
        "enabled": true,
        "environment": 23,
        "identity": null,
        "feature_segment": null
    },
    {
        "id": 27418,
        "feature": {
            "id": 5560,
            "name": "integrations",
            "created_date": "2020-11-05T16:52:57.918094Z",
            "description": "Defines the integrations we display",
            "initial_value": "[\"amplitude\", \"datadog\"]",
            "default_enabled": false,
            "type": "STANDARD"
        },
        "feature_state_value": "[\"amplitude\",\"datadog\",\"new-relic\",\"segment\",\"heap\",\"mixpanel\"]",
        "enabled": true,
        "environment": 23,
        "identity": null,
        "feature_segment": null
    },
    {
        "id": 27481,
        "feature": {
            "id": 5564,
            "name": "integration_data",
            "created_date": "2020-11-06T20:17:13.139643Z",
            "description": "Integration config for different providers",
            "initial_value": "{\n  \"datadog\": {\n    \"perEnvironment\": false,\n    \"image\": \"https://www.vectorlogo.zone/logos/datadoghq/datadoghq-icon.svg\",\n    \"fields\": [\n      {\n        \"key\": \"base_url\",\n        \"label\": \"Base URL\"\n      },\n      {\n        \"key\": \"api_key\",\n        \"label\": \"API Key\"\n      }\n    ],\n    \"tags\": [\n      \"logging\"\n    ],\n    \"title\": \"Data dog\",\n    \"description\": \"Sends events to Data dog for when flags are created, updated and removed. Logs are tagged with the environment they came from e.g. production.\"\n  },\n  \"amplitude\": {\n    \"perEnvironment\": true,\n    \"image\": \"https://braze-marketing-assets.s3.amazonaws.com/images/partner_logos/amplitude-1.png\",\n    \"fields\": [\n      {\n        \"key\": \"api_key\",\n        \"label\": \"API Key\"\n      }\n    ],\n    \"tags\": [\n      \"analytics\"\n    ],\n    \"title\": \"Amplitude\",\n    \"description\": \"Sends data on what flags served to each identity.\"\n  }\n}",
            "default_enabled": false,
            "type": "STANDARD"
        },
        "feature_state_value": "{\n    \"datadog\": {\n        \"perEnvironment\": false,\n        \"image\": \"https://app.flagsmith.com/images/integrations/datadog.svg\",\n        \"docs\": \"https://docs.flagsmith.com/integrations/datadog/\",\n        \"fields\": [{\n            \"key\": \"base_url\",\n            \"label\": \"Base URL\"\n        }, {\n            \"key\": \"api_key\",\n            \"label\": \"API Key\"\n        }],\n        \"tags\": [\"logging\"],\n        \"title\": \"Datadog\",\n        \"description\": \"Sends events to Datadog for when flags are created, updated and removed. Logs are tagged with the environment they came from e.g. production.\"\n    },\n    \"amplitude\": {\n        \"perEnvironment\": true,\n        \"image\": \"https://app.flagsmith.com/images/integrations/amplitude.svg\",\n        \"docs\": \"https://docs.flagsmith.com/integrations/amplitude/\",\n        \"fields\": [{\n            \"key\": \"api_key\",\n            \"label\": \"API Key\"\n        }],\n        \"tags\": [\"analytics\"],\n        \"title\": \"Amplitude\",\n        \"description\": \"Sends data on what flags served to each identity.\"\n    },\n    \"new-relic\": {\n        \"perEnvironment\": false,\n        \"image\": \"https://app.flagsmith.com/images/integrations/new_relic.svg\",\n        \"docs\": \"https://docs.flagsmith.com/integrations/newrelic\",\n        \"fields\": [{\n            \"key\": \"base_url\",\n            \"label\": \"New Relic Base URL\"\n        }, {\n            \"key\": \"api_key\",\n            \"label\": \"New Relic API Key\"\n        }, {\n            \"key\": \"app_id\",\n            \"label\": \"New Relic Application ID\"\n        }],\n        \"tags\": [\"analytics\"],\n        \"title\": \"New Relic\",\n        \"description\": \"Sends events to New Relic for when flags are created, updated and removed.\"\n    },\n    \"segment\": {\n        \"perEnvironment\": true,\n        \"image\": \"https://app.flagsmith.com/images/integrations/segment.svg\",\n        \"docs\": \"https://docs.flagsmith.com/integrations/segment\",\n        \"fields\": [{\n            \"key\": \"api_key\",\n            \"label\": \"API Key\"\n        }],\n        \"tags\": [\"analytics\"],\n        \"title\": \"Segment\",\n        \"description\": \"Sends data on what flags served to each identity.\"\n    },\"heap\": {\n        \"perEnvironment\": true,\n        \"image\": \"https://app.flagsmith.com/images/integrations/heap.svg\",\n        \"docs\": \"https://docs.flagsmith.com/integrations/heap\",\n        \"fields\": [{\n            \"key\": \"api_key\",\n            \"label\": \"API Key\"\n        }],\n        \"tags\": [\"analytics\"],\n        \"title\": \"Heap Analytics\",\n        \"description\": \"Sends data on what flags served to each identity.\"\n    },\"mixpanel\": {\n        \"perEnvironment\": true,\n        \"image\": \"https://app.flagsmith.com/images/integrations/mixpanel.svg\",\n        \"docs\": \"https://docs.flagsmith.com/integrations/mixpanel\",\n        \"fields\": [{\n            \"key\": \"api_key\",\n            \"label\": \"API Key\"\n        }],\n        \"tags\": [\"analytics\"],\n        \"title\": \"Mixpanel\",\n        \"description\": \"Sends data on what flags served to each identity.\"\n    }\n}",
        "enabled": true,
        "environment": 23,
        "identity": null,
        "feature_segment": null
    },
    {
        "id": 29558,
        "feature": {
            "id": 6006,
            "name": "usage_chart",
            "created_date": "2020-11-28T11:36:45.715798Z",
            "description": "Display influx usage chart and number",
            "initial_value": null,
            "default_enabled": false,
            "type": "STANDARD"
        },
        "feature_state_value": null,
        "enabled": true,
        "environment": 23,
        "identity": null,
        "feature_segment": null
    },
    {
        "id": 34292,
        "feature": {
            "id": 6903,
            "name": "scaleup_audit",
            "created_date": "2021-01-27T20:41:28.931473Z",
            "description": "Disables audit log for anyone under scaleup",
            "initial_value": null,
            "default_enabled": false,
            "type": "STANDARD"
        },
        "feature_state_value": null,
        "enabled": false,
        "environment": 23,
        "identity": null,
        "feature_segment": null
    },
    {
        "id": 35671,
        "feature": {
            "id": 7168,
            "name": "butter_bar",
            "created_date": "2021-02-10T20:03:43.348556Z",
            "description": "Show html in a butter bar for certain users",
            "initial_value": null,
            "default_enabled": false,
            "type": "STANDARD"
        },
        "feature_state_value": "<strong>\nYou are using the develop environment.\n</strong>",
        "enabled": true,
        "environment": 23,
        "identity": null,
        "feature_segment": null
    },
    {
        "id": 37186,
        "feature": {
            "id": 7460,
            "name": "flag_analytics",
            "created_date": "2021-02-23T18:53:11.138355Z",
            "description": "Surface analytics when viewing a flag",
            "initial_value": null,
            "default_enabled": false,
            "type": "STANDARD"
        },
        "feature_state_value": null,
        "enabled": true,
        "environment": 23,
        "identity": null,
        "feature_segment": null
    },
    {
        "id": 41662,
        "feature": {
            "id": 8266,
            "name": "dark_mode",
            "created_date": "2021-03-28T11:18:17.782264Z",
            "description": "Controlled via segments, determines if the user has dark mode on",
            "initial_value": null,
            "default_enabled": false,
            "type": "STANDARD"
        },
        "feature_state_value": null,
        "enabled": false,
        "environment": 23,
        "identity": null,
        "feature_segment": null
    },
    {
        "id": 44942,
        "feature": {
            "id": 8798,
            "name": "read_only_mode",
            "created_date": "2021-04-24T10:17:23.574373Z",
            "description": "Determines if org needs to contact sales",
            "initial_value": null,
            "default_enabled": false,
            "type": "STANDARD"
        },
        "feature_state_value": null,
        "enabled": false,
        "environment": 23,
        "identity": null,
        "feature_segment": null
    },
    {
        "id": 53307,
        "feature": {
            "id": 10202,
            "name": "saml",
            "created_date": "2021-06-23T17:40:39.556589Z",
            "description": "Enables SAML auth",
            "initial_value": null,
            "default_enabled": false,
            "type": "STANDARD"
        },
        "feature_state_value": null,
        "enabled": true,
        "environment": 23,
        "identity": null,
        "feature_segment": null
    },
    {
        "id": 59621,
        "feature": {
            "id": 11243,
            "name": "clone_environment",
            "created_date": "2021-08-02T12:13:36.234860Z",
            "description": "adds the ability to clone an environment",
            "initial_value": null,
            "default_enabled": false,
            "type": "STANDARD"
        },
        "feature_state_value": null,
        "enabled": false,
        "environment": 23,
        "identity": null,
        "feature_segment": null
    },
    {
        "id": 62248,
        "feature": {
            "id": 11639,
            "name": "payments_enabled",
            "created_date": "2021-08-15T15:42:53.454540Z",
            "description": "Determines whether to show payment UI / seats",
            "initial_value": null,
            "default_enabled": true,
            "type": "STANDARD"
        },
        "feature_state_value": null,
        "enabled": true,
        "environment": 23,
        "identity": null,
        "feature_segment": null
    },
    {
        "id": 62798,
        "feature": {
            "id": 11727,
            "name": "disable_create_org",
            "created_date": "2021-08-16T17:18:28.052286Z",
            "description": "Turning this on will prevent users from creating any additional organisations",
            "initial_value": null,
            "default_enabled": false,
            "type": "STANDARD"
        },
        "feature_state_value": null,
        "enabled": false,
        "environment": 23,
        "identity": null,
        "feature_segment": null
    }
]''';
final fakeIdentitiesResponse = r'''{
    "flags": [
        {
          "id": 48540,
          "feature": {
              "id": 9368,
              "name": "fake_disabled_feature",
              "created_date": "2021-05-24T08:38:29.203517Z",
              "description": "Fake Disabled feature",
              "initial_value": null,
              "default_enabled": false,
              "type": "STANDARD"
          },
          "feature_state_value": null,
          "enabled": false,
          "environment": 7822,
          "identity": null,
          "feature_segment": null
        },
        {
            "id": 48541,
            "feature": {
                "id": 9368,
                "name": "disabled_feature",
                "created_date": "2021-05-24T08:38:29.203517Z",
                "description": "Disabled feature",
                "initial_value": null,
                "default_enabled": false,
                "type": "STANDARD"
            },
            "feature_state_value": null,
            "enabled": false,
            "environment": 7822,
            "identity": null,
            "feature_segment": null
        },
        {
            "id": 48543,
            "feature": {
                "id": 9369,
                "name": "enabled_feature",
                "created_date": "2021-05-24T08:38:47.375641Z",
                "description": "Enabled test feature",
                "initial_value": null,
                "default_enabled": true,
                "type": "STANDARD"
            },
            "feature_state_value": null,
            "enabled": true,
            "environment": 7822,
            "identity": null,
            "feature_segment": null
        },
        {
            "id": 48545,
            "feature": {
                "id": 9370,
                "name": "min_version",
                "created_date": "2021-05-24T08:39:05.095219Z",
                "description": "test min version",
                "initial_value": "1.0.1",
                "default_enabled": true,
                "type": "STANDARD"
            },
            "feature_state_value": "2.0.0",
            "enabled": true,
            "environment": 7822,
            "identity": null,
            "feature_segment": null
        },
        {
            "id": 48547,
            "feature": {
                "id": 9371,
                "name": "my_feature",
                "created_date": "2021-05-24T08:39:24.938442Z",
                "description": "My feature",
                "initial_value": null,
                "default_enabled": false,
                "type": "STANDARD"
            },
            "feature_state_value": "my_feature_value",
            "enabled": true,
            "environment": 7822,
            "identity": null,
            "feature_segment": null
        },
        {
            "id": 48549,
            "feature": {
                "id": 9372,
                "name": "show_title_logo",
                "created_date": "2021-05-24T08:40:25.683907Z",
                "description": "Show logo in Navigation bar",
                "initial_value": null,
                "default_enabled": false,
                "type": "STANDARD"
            },
            "feature_state_value": null,
            "enabled": false,
            "environment": 7822,
            "identity": null,
            "feature_segment": null
        },
        {
            "id": 52786,
            "feature": {
                "id": 10101,
                "name": "max_version",
                "created_date": "2021-06-20T07:14:26.446931Z",
                "description": "Max version of package",
                "initial_value": "3.0.0",
                "default_enabled": false,
                "type": "STANDARD"
            },
            "feature_state_value": "3.0.0",
            "enabled": false,
            "environment": 7822,
            "identity": null,
            "feature_segment": null
        }
    ],
    "traits": [
       {
            "id": 17043795,
            "trait_key": "age",
            "trait_value": 25
        },
        {
            "id": 17043796,
            "trait_key": "age2",
            "trait_value": true
        }
    ]
}''';

final bulkTraitUpdateResponse = '''[
  {
      "identity": {
          "identifier": "test_another_user"
      },
      "trait_key": "age",
      "trait_value": "21"
  },
  {
    "identity": {
        "identifier": "test_another_user"
    },
    "trait_key": "age2",
    "trait_value": "21"
  }
]''';

final createTraitRequest = '''{
  "identifier": "test_another_user"
  "flags":[
    {
        "trait_key": "age",
        "trait_value": "21"
    },
    {
      "trait_key": "age2",
      "trait_value": "21"
    }
  ]
}''';

final traitAge25 = '''{
  "identity": {
    "identifier": "test_another_user"
  },
  "trait_key": "age",
  "trait_value": "25"
}''';

final analyticsData = '''{
  "my_feature": 2
}''';

Future<FlagsmithClient> setupClientAdapter(
  StorageType storeType, {
  bool caches = false,
  bool isDebug = false,
}) async {
  final fs = await FlagsmithClient.init(
    apiKey: apiKey,
    seeds: seeds,
    config: FlagsmithConfig(
      storageType: storeType,
      isDebug: isDebug,
      baseURI: 'https://offline.net/',
      caches: caches,
    ),
    storage: storeType == StorageType.custom ? InMemoryStorage() : null,
  );

  fs.loading.listen((event) {
    fs.log('loading [$storeType]: $event');
  });
  return fs;
}

FlagsmithClient setupSyncClientAdapter(
  StorageType storeType, {
  bool caches = false,
  bool isDebug = false,
  VoidCallback? afterInit,
}) {
  final fs = FlagsmithClient(
    apiKey: apiKey,
    seeds: seeds,
    config: FlagsmithConfig(
      storageType: storeType,
      isDebug: isDebug,
      baseURI: 'https://offline.net/',
      caches: caches,
    ),
    storage: storeType == StorageType.custom ? InMemoryStorage() : null,
  );
  return fs;
}

void setupAdapter(FlagsmithClient fs,
    {Function(FlagsmithConfig, DioAdapter)? cb}) async {
  final config = fs.config;

  final dioAdapter = DioAdapter(dio: fs.client);
  dioAdapter.onGet(
      config.flagsURI, (server) => server.reply(200, jsonDecode(fakeResponse)));
  dioAdapter.onGet(config.identitiesURI,
      (server) => server.reply(200, jsonDecode(fakeIdentitiesResponse)));

  if (cb != null) {
    cb(config, dioAdapter);
  }
}

void setupEmptyAdapter(FlagsmithClient fs,
    {Function(FlagsmithConfig, DioAdapter)? cb}) async {
  final config = fs.config;
  final dioAdapter = DioAdapter(dio: fs.client);
  if (cb != null) {
    cb(config, dioAdapter);
  }
}
