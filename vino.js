var VINO_VERSION = "0.0.1";
var VINO_DEFAULT_OPTS = {
	baseUrl: 'https://api.vineapp.com/',
	debug: 0,
	userAgent: 'com.vine.iphone/1.0.7 (unknown, iPhone OS 6.1.2, iPhone, Scale/2.000000)'
};

// use browser-request if available, fall back to npm request
if (typeof request == 'undefined') {
	var request = require('request');
}

function Vino(options) {
	options = options || {};
  if ('sessionId' in options) {
    this.sessionId = options.sessionId;
  }
	this.opts = extend(VINO_DEFAULT_OPTS, options);
	this.debug(this.opts);
}

Vino.prototype.debug = function(args) {
};

Vino.prototype.homeFeed = function(callback) {
	if (!('sessionId' in this))
		throw new Error('must be logged in');
	var bu = this.opts.baseUrl, that = this;
	request(
		{
			url: bu+'timelines/graph',
			method: 'get',
			headers: {
				'vine-session-id': this.sessionId,
				'User-Agent': this.opts.userAgent
			}
		},
		function (err, resp, body) {
			that.debug('homeFeed response', err, resp, body);
			if (err) {
				callback(err, resp);
				return;
			}
			body = JSON.parse(body);
			if (body.code) {
				callback('homeFeed failure', body);
			}
			callback(null, body.data);
		}
	);
};

Vino.prototype.login = function(callback) {
	if (!('username' in this.opts) ||
			!('password' in this.opts))
		throw new Error('username and password required to login');
	var bu = this.opts.baseUrl, that = this;
	request(
		{
			url: bu+'users/authenticate',
			method: 'post',
			form: { 
				username: this.opts.username,
				deviceToken: this.opts.deviceToken,
				password: this.opts.password
			},
			headers: {
				'User-Agent': this.opts.userAgent
			}
		},
		function (err, resp, body) {
      body = JSON.parse(body);
      if (!body.success) {
        callback('login failure', body);
        return;
      }
      that.sessionId = body.data.key;
      that.userId = body.data.userId;
      that.debug('session id', that.sessionId);
      callback(null, that.sessionId, that.userId, that);
		}
	);
};

Vino.prototype.register = function(username, email, password, callback) {
  var bu = this.opts.baseUrl, that = this;
  request(
    {
      url: bu+'users',
      method: 'post',
      form: {
        username: username,
        email: email,
        authenticate: 1,
        password: password
      },
      headers: {
        'User-Agent': this.opts.userAgent
      }
    },
    function(err, resp, body) {
      body = JSON.parse(body);
      if (!body.success) {
        callback('register failure', body);
        return;
      }
      that.sessionId = body.data.key;
      that.userId = body.data.userId;
      that.debug('session id', that.sessionId);
      callback(null, that.sessionId, that.userId, that);
    }
  );
};


Vino.prototype.revine = function(params) {
	if (!('sessionId' in this))
		throw new Error('must be logged in');
  var bu = this.opts.baseUrl, that = this;
  params.allowReshare = params.allowReshare || 1;
  request(
    {
      url: bu+'posts',
      method: 'post',
			form: params,
      headers: {
				'vine-session-id': this.sessionId,
				'User-Agent': this.opts.userAgent
      }
    },
    function (err, resp, body) {
      console.log(params);
      console.log(body);
			that.debug('revine response', err, resp, body);
    }
  );
};

Vino.prototype.tagSearch = function(tag, callback) {
	if (!('sessionId' in this))
		throw new Error('must be logged in');
	var bu = this.opts.baseUrl, that = this;
	request(
		{
			url: bu+'timelines/tags/'+encodeURIComponent(tag),
			method: 'get',
			headers: {
				'vine-session-id': this.sessionId,
				'User-Agent': this.opts.userAgent
			}
		},
		function (err, resp, body) {
			that.debug('tagSearch response', err, resp, body);
			if (err) {
				callback(err, resp);
				return;
			}
			body = JSON.parse(body);
			if (body.code) {
				callback('tagSearch failure', body);
			}
			callback(null, body.data);
		}
	);
};

function extend(target) {
	for (var i = 1; i < arguments.length; i++) {
		var source = arguments[i],
		keys = Object.keys(source);

		for (var j = 0; j < keys.length; j++) {
			var name = keys[j];
			target[name] = source[name];
		}
	}

	return target;
}

if (typeof module == 'undefined') 
	window.Vino = Vino;
else 
	module.exports = Vino;
