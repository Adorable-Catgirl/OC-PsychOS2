if component.list("chat_box")() then
 function dprint(...)
  for k,v in pairs({...}) do
   component.invoke(component.list("chat_box")(),"say",v)
  end
 end
end
