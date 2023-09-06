<?php

namespace App\Http\Controllers\Test;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Mail;
class TestController extends Controller
{
    public function fnmail()
        { 
            $name = 'HOLA';
            $email = 'asagula@vaclog.com';
            $data = array('name'=>$name);
            Mail::send('mail', $data, function($message) use ($name, $email) {
            $message->to($email, $name)
                    ->subject('Subject');  //to redirect mail.blade.php page
            $message->from('opespeciales@itservices.vaclog.com','DoNotReply');
        });
}
}
