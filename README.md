[![Circle CI](https://circleci.com/gh/unageanu/jiji2.png?circle-token=e29eaf60c31708f4b2b407d9d2e8f3aa00672fdd)](https://circleci.com/gh/unageanu/jiji2)
[![Code Climate](https://codeclimate.com/github/unageanu/jiji2/badges/gpa.svg)](https://codeclimate.com/github/unageanu/jiji2)
[![Test Coverage](https://codeclimate.com/github/unageanu/jiji2/badges/coverage.svg)](https://codeclimate.com/github/unageanu/jiji2)

# Jiji (Beta)<br/>

<b>Start the Forex system trading, using your own trading strategies.</b>
<br/><br/>
Jiji is a forex algorithmic trading framework using [OANDA REST API](http://developer.oanda.com/).

[lean more...](http://jiji2.unageanu.net/) (sorry, this page is japanese only.)

# Contributing to Jiji

We'd love for you to contribute to our source code and to make Jiji even better than it is today!

1. Fork this repository on github.

    ```shell
    $ git clone -b develop https://github.com/unageanu/jiji2.git
    ```

2. Setup MongoDB.

    ```shell
    $ docker pull mongo
    $ docker run --name mongo -d mongo
    ```

3. Make your changes.

4. Add tests where applicable and run the existing tests with rspec and jasmine to make sure they all pass.

    ```
    $ export OANDA_API_ACCESS_TOKEN=<YOUR OANDA API ACCESS TOKEN FOR DEMO>
    $ bundle install
    $ bundle exec rake
    $ cd sites
    $ npm install
    $ gulp  
    ```

5. Create a new pull request for `develop` branch and submit it to me.


# License

---
Copyright (c) unageanu <masaya.yamauchi>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
