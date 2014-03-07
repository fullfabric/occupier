module Occupier
  
  class Exception < RuntimeError; end;

  class NotFound          < Exception; end;
  class AlreadyExists     < Exception; end;
  class InvalidTenantName < Exception; end;

end