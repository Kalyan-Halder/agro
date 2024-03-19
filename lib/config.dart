//const url = 'http://192.168.0.111:3000/';
const url = 'https://fancy-gray-viper.cyclic.app/';
const user = url + 'user';
const login = url +'login';
const register = url + 'register';
const update_user = url + 'update';
const send_mail = url + 'forget-password';
const verify = url + 'verify-user';


//for chat
const chat = url+'message';
const chat_local = url + 'ask';


//Product related routes;
const seller_products = url+'seller_products';
const add = url+'add_product';
const delete = url+'delete_product';
const update_product = url+'update_product';
const product_lsit = url+'all_product';
const set_image_dis = url+'set_image_dis';
const get_image = url+'get_image';


//for cart list
const add_to_cart = url+'add_to_cart';
const get_cart_digit = url + 'get_cart_digit';
const get_cart_details = url+'get_cart_details';
const delete_cart = url+'delete_cart';


//for order list
const create_order = url+'create_order';
const orders = url + 'orders';
const orders_buyer = url + 'orders_buyer';
const update_order = url + 'update_order';


//Local Item Graph
const get_graph = url+'top_product_graph';
const top_products = url+'best_product';

//for admin
const fetch_for_admin_products = url + "fetch_unauthorized_for_admin_products";
const fetch_true_products = url + 'fetch_authorized_for_admin_products';
const update_product_status = url+'update_product_status';
const fetch_all_product = url + "fetch_all_product";
