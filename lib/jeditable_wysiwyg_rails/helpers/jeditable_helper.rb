module JeditableHelper
  # If the <tt>condition</tt> evaluates to <tt>true</tt>, an editable field
  # will be created.  Otherwise, the value of the property of the object is
  # returned.  See #editable_field for options.
  def editable_field_if(condition, object, property, options={})
    if condition
      editable_field(object, property, options)
    else
      object.send property
    end
  end

  # Creates an editable span for the given property of the given object.
  #
  # === Options
  #
  # [:method]
  #   Specify the HTTP method to use: <tt>'PUT'</tt> or <tt>'POST'</tt>.
  # [:name]
  #   The <tt>name</tt> attribute to be used when the form is posted.
  # [:update_url]
  #   The URL to submit the form to.  Defaults to <tt>url_for(object)</tt>.
  def editable_field(object, property, options={})
    name = "#{object.class.to_s.underscore}[#{property}]"
    value = object.send property
    update_url = options.delete(:update_url) || url_for(object)
    args = {:method => 'PUT', :name => name}.merge(options)
    %{
      <span class="editable" data-id="#{object.id}" data-name="#{name}">#{value}</span>
      <script type="text/javascript">
        (function( $ ){
          $(function(){
            var args = {data: function(value, settings) {
              // Unescape HTML
              var retval = value
                .replace(/&amp;/gi, '&')
                .replace(/&gt;/gi, '>')
                .replace(/&lt;/gi, '<')
                .replace(/&quot;/gi, "\\\"");
              return retval;
            }};
            $.extend(args, #{args.to_json});
            $(".editable[data-id='#{object.id}'][data-name='#{name}']").editable("#{update_url}", args);
          });
        })( jQuery );
      </script>
    }.html_safe
  end

  # Creates an editable span for the given property of the given object,
  # with the edit triggered by a click on the following "Edit" div (which
  # may be styled into a button). This essentially wraps the editable_field
  # helper with some extra HTML.
  def editable_with_trigger(object, property, options={})
    name = "#{object.class.to_s.underscore}[#{property}]"
    trigger_name = "#{object.class.to_s.underscore}[#{property}]_trigger"
    args = { :event => 'edit-click', :edit_string => 'Edit' }.merge(options) # bind the edit trigger to 'edit-click'
    # Add the trigger span
    %{
      #{editable_field(object, property, args)}
      <span class="edit_trigger" id="#{trigger_name}">#{args[:edit_string]}</span>
      <script type="text/javascript">
        /* Find and trigger "edit-click" event on correct Jeditable instance. */
        $(".edit_trigger[id='#{trigger_name}']").bind("click", function() {
            $(".editable[data-id='#{object.id}'][data-name='#{name}']").trigger("edit-click");
        });
      </script>
    }.html_safe
  end
end

