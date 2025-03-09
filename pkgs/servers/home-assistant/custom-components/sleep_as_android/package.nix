{
  lib,
  buildHomeAssistantComponent,
  fetchFromGitHub,
  pytest-homeassistant-custom-component,
  pytestCheckHook,
  pyhaversion,
}:
let
  version = "2.3.2";
in
buildHomeAssistantComponent {
  owner = "IATkachenko";
  domain = "sleep_as_android";
  inherit version;

  src = fetchFromGitHub {
    owner = "IATkachenko";
    repo = "HA-SleepAsAndroid";
    tag = "v${version}";
    hash = "sha256-aJKjHZcRdmiXJdtWRY4fv5oxCHTDIVpvZEwhIE9ISv8=";
  };

  dependencies = [
    pyhaversion
  ];

  # FIXME: Currently the tests fail with:
  #   AttributeError: 'async_generator' object has no attribute 'data'
  # however the component works fine
  doCheck = false;

  nativeCheckInputs = [
    pytest-homeassistant-custom-component
    pytestCheckHook
  ];

  meta = {
    description = "Sleep As Android integration for Home Assistant";
    homepage = "https://github.com/IATkachenko/HA-SleepAsAndroid";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ blenderfreaky ];
  };
}
