Mpay Gateway
============

This integrates the [mPAY24](https://www.mpay24.com/web/en/mpay24-payment-platform.html)
payment gateway into Spree. mPAY24 is an European credit card and mobile phone payment
processing gateway.

The plugin takes care of basic security:

* transferred data is secured by a salt
* no credit card data is stored within the spree web shop
* the identity of the confirmation callback is verified

The plugin was tested with multiple web shops implemented by [we](http://wwww.starseeders.net).

Installation
============

This plugin has been tested with Spree 0.11.2 and Spree 0.40.3.

Spree 0.11
----------

Install it as a git submodule. To do this execute the following within your application
directory:

<blockquote>
 git clone git://github.com/andreashappe/spree-mpay24 vendor/extensions/mpay_gateway
 cd vendor/extensions/mpay_gateway
 git checkout spree-0.11
</blockquote>

Spree 0.40
----------

Install the gem from [rubygems](https://rubygems.org/gems/mpay_gateway) through

<blockquote>
	gem install mpay_gateway
</blockquote>

And include it in your Project's Gemfile

<blockquote>
	gem 'mpay_gateway'
</blockquote>

Configuration
=============

Add a payment method of provider type BillingIntegration:Mpay. The
payment method comes with a configuration pane which allows setting
of basic options as:

* merchant id (for both testing as well as production mpay mode)
* shared secret (which is used as salt to secure the communication)
* base url (the URL of your website, this is needed for the confirmation callback from mPAY24)

License stuff
=============

Copyright © 2010 Andreas Happe <andreashappe@starseeders.net>

This plugin is free software; you can redistribute it and/or
modify it either under the terms of the GNU Lesser General Public
License version 2.1 as published by the Free Software Foundation
(the "LGPL") or, at your option, under the terms of the Mozilla
Public License Version 1.1 (the "MPL"). If you do not alter this
notice, a recipient may use your version of this file under either
the MPL or the LGPL.

You should have received a copy of the LGPL along with this library
in the file COPYING-LGPL-2.1; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Suite 500, Boston, MA 02110-1335, USA

This software is distributed on an "AS IS" basis, WITHOUT WARRANTY
OF ANY KIND, either express or implied. See the LGPL or the MPL for
the specific language governing rights and limitations.
