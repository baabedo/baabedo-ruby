Next (?/?/?)
==================

#### Features

* Added `proxy` option to allow RestClient http proxies.
* Added Baabedo::Order
* Added search action (pagination is missing)
* Show Request-Id in error if present

0.0.4 (23/08/2015)
==================

#### Fixes

* Use PUT for resource updates.
* Fixed some error handling.

0.0.3 (12/08/2015)
==================

#### Fixes

* Fixed namespace conficts. If a `Company` class existed, the client tried to construct that instead of a `Baabedo::Company`

0.0.2 (12/07/2015)
==================

#### Fixes

* Fixed exception when using Baabedo::Client.use and verify_ssl_certs is specified

0.0.1 (04/07/2015)
==================

Initial Release
