import Launch from 'appkit/routes/launch';

var route;
module("Unit - LaunchRoute", {
  setup: function(){
    var container = isolatedContainer([
      'route:launch'
    ]);

    route = container.lookup('route:launch');
  }
});

test("it exists", function(){
  ok(route);
  ok(route instanceof Launch);
});

//test("#model", function(){
  //deepEqual(route.model(), ['red', 'yellow', 'blue']);
//});
