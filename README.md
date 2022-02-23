# linux-systemd-amdgpu-adaptive-thermal-limiter

A systemd service which adjust power on AMD GPU devices every minute to
keep certain temperature.

## Why?

Some HPC GPUs from AMD have high thermal output. This keeps temperatures
low along with power consumption.

## How?

Simple alogrithm that checks power percentage on relative scale from min
to max and adjust power cap accordingly.

## Configuration

Have a similar line in your `/etc/miner.env`:

```
AMDGPU_BEST_OPERATIONAL_TEMPERATURE="70000"
```

## Setup

```bash
bash setup.sh
```

## Development

Requires ruby. For TDD-like experience while making changes use:

```bash
bundle install
bundle exec guard
```

It will run docker build each time changes are saved.

## Support

Consider using my [unmineable referral link](https://www.unmineable.com/?ref=3792-egij) (0.75% pool fee instead of 1% for you as well) or [donate](https://github.com/pr0d1r2/donate) or both.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
