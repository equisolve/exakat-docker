Methods that implements an interface in a class must be public. 

PHP doesn't lint this, but won't start a script with a Fatal error : 'Access level to c::iPrivate() must be public (as in class i) ';

<?php

interface i {
    function iPrivate() ;
    function iProtected() ;
    function iPublic() ;
}

class c implements i {
    // Methods that implements an interface in a class must be public.  
    private function iPrivate() {}
    protected function iProtected() {}
    public function iPublic() {}
}

?>

See also [Interfaces](http://php.net/manual/en/language.oop5.interfaces.php).

