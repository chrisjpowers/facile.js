(function() {

  describe('facile', function() {
    describe('binds data', function() {
      it('to ids', function() {
        var data, result, template;
        template = '<div id="dog" />';
        data = {
          dog: 'woof'
        };
        result = facile(template, data);
        return expect(result).toBe('<div id="dog">woof</div>');
      });
      it('to classes if id does not exist', function() {
        var data, result, template;
        template = '<div class="dog" />';
        data = {
          dog: 'woof'
        };
        result = facile(template, data);
        return expect(result).toBe('<div class="dog">woof</div>');
      });
      it('of binding objects', function() {
        var data, expectedHtml, result, template;
        template = '<div id="orders"><div class="order"><div class="name" /></div></div>';
        data = {
          orders: [
            {
              name: 'cool order'
            }, {
              name: 'lame order'
            }
          ]
        };
        result = facile(template, data);
        expectedHtml = '<div id="orders"><div class="order"><div class="name">cool order</div></div><div class="order"><div class="name">lame order</div></div></div>';
        return expect(result).toBe(expectedHtml);
      });
      return it('to tables as rows', function() {
        var data, expectedHtml, result, template;
        template = '<table class="order"><thead><tr><td>Orders</td></tr></thead><tbody><tr><td class="name" /></tr></tbody></table>';
        data = {
          order: [
            {
              name: 'cool order'
            }, {
              name: 'lame order'
            }
          ]
        };
        result = facile(template, data);
        expectedHtml = '<table class="order"><thead><tr><td>Orders</td></tr></thead><tbody><tr><td class="name">cool order</td></tr><tr><td class="name">lame order</td></tr></tbody></table>';
        return expect(result).toBe(expectedHtml);
      });
    });
    describe('binds objects', function() {
      it('to ids', function() {
        var data, result, template;
        template = '<div id="dog" />';
        data = {
          dog: {
            content: 'woof',
            'data-age': 3
          }
        };
        result = facile(template, data);
        return expect(result).toBe('<div id="dog" data-age="3">woof</div>');
      });
      it('to classes', function() {
        var data, result, template;
        template = '<div class="dog" />';
        data = {
          dog: {
            content: 'woof',
            'data-age': 3
          }
        };
        result = facile(template, data);
        return expect(result).toBe('<div class="dog" data-age="3">woof</div>');
      });
      return it('that are nested', function() {
        var data, expectedHtml, result, template;
        template = '<div class="order"><div class="name"><div class="place" /></div></div>';
        data = {
          order: [
            {
              name: {
                content: 'over there',
                place: 'cool order'
              }
            }
          ]
        };
        result = facile(template, data);
        expectedHtml = '<div class="order"><div class="name" place="cool order">over there</div></div>';
        return expect(result).toBe(expectedHtml);
      });
    });
    describe('binding arrays', function() {
      xit('binds to class and id');
      it('of binding objects', function() {
        var data, result, template;
        template = '<div id="dogs"><div class="dog"><div class="speak" /></div></div>';
        data = {
          dogs: [
            {
              speak: 'woof'
            }, {
              speak: 'bark'
            }
          ]
        };
        result = facile(template, data);
        return expect(result).toBe('<div id="dogs"><div class="dog"><div class="speak">woof</div></div><div class="dog"><div class="speak">bark</div></div></div>');
      });
      xit('of content objects', function() {
        var data, result, template;
        template = '<div id="dogs"><div class="dog" /></div>';
        data = {
          dogs: [
            {
              content: 'woof',
              'data-age': 3
            }, {
              content: 'bark',
              'data-peak': 27
            }
          ]
        };
        result = facile(template, data);
        return expect(result).toBe('<div id="dogs"><div class="dog" data-age="3">woof</div><div class="dog" data-peak="27">bark</div></div>');
      });
      return xit('ignores if child with same class exists', function() {
        var data, result, template;
        template = '<div class="dog"><h1>Dog Time!</h1><div class="dogs" /></div>';
        data = {
          dogs: ['woof', 'bark']
        };
        result = facile(template, data);
        return expect(result).toBe('<div class="dogs"><h1>Dog Time!</h1><div class="dogs">woof</div><div class="dogs">bark</div></div>');
      });
    });
    describe('binds nulls', function() {
      it('by removing elements by id', function() {
        var data, result, template;
        template = '<div id="dog" />';
        data = {
          dog: null
        };
        result = facile(template, data);
        return expect(result).toBe('');
      });
      it('by removing elements by class', function() {
        var data, result, template;
        template = '<div class="dog" />';
        data = {
          dog: null
        };
        result = facile(template, data);
        return expect(result).toBe('');
      });
      return it('when they are nested', function() {
        var data, expectedHtml, result, template;
        template = '<div class="order"><div class="name"><div class="place" /></div></div>';
        data = {
          order: [
            {
              name: {
                place: null
              }
            }
          ]
        };
        result = facile(template, data);
        expectedHtml = '<div class="order"><div class="name"></div></div>';
        return expect(result).toBe(expectedHtml);
      });
    });
    return describe('appends classes', function() {
      it('to objects bound via classes', function() {
        var data, result, template;
        template = '<div class="dog" />';
        data = {
          dog: {
            content: 'woof',
            'class': 'spaniel'
          }
        };
        result = facile(template, data);
        return expect(result).toBe('<div class="dog spaniel">woof</div>');
      });
      it('to objects bound via ids', function() {
        var data, result, template;
        template = '<div id="dog" />';
        data = {
          dog: {
            content: 'woof',
            'class': 'spaniel'
          }
        };
        result = facile(template, data);
        return expect(result).toBe('<div id="dog" class="spaniel">woof</div>');
      });
      return it('ignores empty class values', function() {
        var data, result, template;
        template = '<div class="dog" />';
        data = {
          dog: {
            content: 'woof',
            'class': ''
          }
        };
        result = facile(template, data);
        return expect(result).toBe('<div class="dog">woof</div>');
      });
    });
  });

}).call(this);
