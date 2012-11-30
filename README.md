JSON-RPC plugin for MooTools
==========

This is JSON-RPC plugin for MooTools.

Usage
==========

  var rpc = Request.JSONRPC({
    url: '/jsonrpc',
	remoteMethod: 'sum',
	onSuccess: function(result) {
	  console.log(JSON.encode(result);
	},
	onComplete: function() {
	  console.log('complete');
	},
	onFailure: function(xhr) {
	  console.log('Failure');
	},
	onRemoteError: function(error) {
	  console.log(error.code + ' : ' + error.message);
	},
	onIdMismatch: function(result) {
	  console.log(this.xid + '<>' + result.id);
	}
  });
  rpc.send([1,2,3]);
  rpc.send([4,5,6], 'other_sum');

ToDo
==========

Write more...
