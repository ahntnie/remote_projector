class LoginRequestModel {
  final String email;
  final String password;
  final String? fcm_token;
  LoginRequestModel(
      {required this.email, required this.password, this.fcm_token});
}
//  function doLogin() {
//     $email = $this-> getPOST('email');
//     $password = $this-> getPOST('password');
//     //$password = $this->md5Security($password);    
//     $sql  = "select customer_id,customer_name,address,phone_number,email,date_of_birth,sex,chu_tk,stk,nganhang,chinhanh,password, customer_token from customer_list 
//       where  (email ='$email' OR phone_number = '$email' ) and password = '$password' and length(trim('$email')) > 0 and length(trim('$password')) > 0 is not null  and ifnull(deleted,'n') != 'y'";
//         $user = $this->executeResult($sql);
//         $count= count($user);  
//     if ($count>=1) {
//         //$phone_number = $user['phone_number'];
//        // $email = $user['email'];
//         //$customer_id    = $user['customer_id'];
//         //$token = $this->md5Security($phone_number.time().$customer_id);
//         // setcookie('status', 'login', time()+7*24*60*60, '/');
//          // setcookie('token', $token, time()+7*24*60*60, '/');
//         // save database
//         // $sql = "insert into login_tokens (id_user, token) values ('$customer_id', '$token')";
//         //$this->execute($sql,$errortext);
//         $res = [
//             "status" => 1,
//             "msg"    => "Login success!!!",
//             "info"   => $user
//         ];
//     } else {
//          $sql  = "select customer_id,customer_name from customer_list 
//          where  (email ='$email' OR phone_number = '$email' ) and ifnull(deleted,'n') = 'y'";
//         $user = $this->executeResult($sql);
//         $count= count($user);
//         if ($count>=1) {
//             $res = [
//                 "status" => -1,
//                 "msg"    => "User is disable!!!",
//                 "info"   =>$count
//             ];
//         }else{
//             $res = [
//                 "status" => -1,
//                 "msg"    => "password or Username incorect!!!",
//                 "info"   =>$count
//             ];
//         }
//     }
//     echo json_encode($res);
// }