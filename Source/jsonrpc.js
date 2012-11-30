Request.JSONRPC = new Class({

    Extends: Request,

    options: {
        link: 'cancel',
        remoteMethod: null
    },

    xid: '',

    initialize: function(options) {
        options = options || {};
        options.method   = 'post';
        options.encoding = 'utf-8';
        options.headers  = {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
        };
        this.parent(options);
    },

    send: function(params, method, id) {
        this.xid = id || String.uniqueID();
        this.parent(JSON.encode({
            jsonrpc: '2.0',
            id: this.xid,
            method: method || this.options.remoteMethod,
            params: params
        }));
    },

    success: function(text) {
        var response;
        try {
            response = JSON.decode(text, true);
        }
        catch (error) {
            this.fireEvent('failure', [this.xhr, 'Failed to decode json', text]);
        }
        if (typeOf(response) !== 'object') {
            this.fireEvent('failure', [this.xhr, 'Invalid response type', text]);
        }
        else if (response.id !== this.xid) {
            this.fireEvent('idMismatch', response);
        }
        else if (response.error) {
            this.fireEvent('remoteError', response.error);
        }
        else {
            this.fireEvent('success', response.result);
        }
    }
});
