// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
function startMenuList()
{
 if (document.all && document.getElementById)
 {
   AddClasses(document.getElementById("toolbar_menu_list_id"));
   AddClasses(document.getElementById("user_toolbar_list_id"));
   AddClasses(document.getElementById("site_toolbar_list_id"));
 }
}

function AddClasses(navRoot)
{
  var re = new RegExp('\\bselected\\b', 'i');
  for (i=0; i<navRoot.childNodes.length; i++)
  {
    node = navRoot.childNodes[i];
    if (node.nodeName=="LI")
    {
      node.onmouseover=function() {
        if (this.className.search(re) != -1)
          this.className+=" active_over";
        else
          this.className+=" over";
      }
      node.onmouseout=function() {
        this.className=this.className.replace(" over", "");
        this.className=this.className.replace(" active_over", "");
      }
    }
  }
}

/*-------------- pagination ajax ---------------*/
document.observe("dom:loaded", function() {
  // the element in which we will observe all clicks and capture
  // ones originating from pagination links
  var container = $(document.body)

  if (container) {

    function createSpinner() {
      return new Element('img', { src: '/images/admin/icons/loading.gif', 'class': 'spinner' })
    }

    container.observe('click', function(e) {
      var el = e.element()
      if (el.match('.pagination.ajax a')) {
        el.up('.pagination.ajax').insert(createSpinner())
        new Ajax.Request(el.href, { method: 'get' })
        e.stop()
      }
    })
  }
})

/*-------------------- Product Administration Functions ------------------------------*/
var Product = {
  product_id: null,
  form_authenticity_token: null,

  linkCollection: function(collection_id, linkage) {
    var highlight = function(){ new Effect.Highlight('collection_'+collection_id+'_wrapper', {endcolor: '#F4F9FB'}); };

    if(linkage) {
      new Ajax.Request('/admin/products/'+this.product_id+'/add_to_collection' , {method: 'POST', parameters: 'context=none&authenticity_token='+this.form_authenticity_token+'&collection_id='+collection_id, onSuccess: highlight} );
    }
    else {
      new Ajax.Request('/admin/products/'+this.product_id+'/remove_from_collection', {parameters: 'context=none&authenticity_token='+this.form_authenticity_token+'&collection_id='+collection_id, method: 'DELETE', onSuccess: highlight});
    }
  },

  defaultCollection: function() {
    var highlight = function(){ new Effect.Highlight('default_collection_wrapper', {endcolor: '#F4F9FB'}); };
    var collection_id = $F('default_collection_id')
    new Ajax.Request('/admin/products/'+this.product_id+'/update_default_collection', {parameters: 'context=none&authenticity_token='+this.form_authenticity_token+'&collection_id='+collection_id, method: 'POST', onSuccess: highlight});
  }
}

//toggleFromRadio
function toggleFromRadio(selection, toggle_value, toggle_class) {
  radio_divs = $$('div.' + toggle_class);
  radio_divs.each(function(item) {
    if (item.id == selection.value + toggle_value)
      item.show();
    else
      item.hide();
  });
}

document.observe("dom:loaded", startMenuList);
