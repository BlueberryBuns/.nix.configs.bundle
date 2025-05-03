{ ... }:
{
  imports = [
    ./core

    ./optional
  ];
  services.ssh-agent.enable = true;
}
