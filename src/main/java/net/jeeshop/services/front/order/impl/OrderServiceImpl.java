package net.jeeshop.services.front.order.impl;import java.util.List;import org.apache.commons.lang.StringUtils;import org.slf4j.LoggerFactory;import org.springframework.beans.factory.annotation.Autowired;import org.springframework.stereotype.Service;import org.springframework.transaction.annotation.Transactional;import net.jeeshop.core.FrontContainer;import net.jeeshop.core.ServersManager;import net.jeeshop.core.front.SystemManager;import net.jeeshop.core.pay.alipay.newpay.AlipaynewConfig;import net.jeeshop.services.front.account.AccountService;import net.jeeshop.services.front.account.bean.Account;import net.jeeshop.services.front.order.OrderService;import net.jeeshop.services.front.order.bean.Order;import net.jeeshop.services.front.order.bean.OrderSimpleReport;import net.jeeshop.services.front.order.dao.OrderDao;import net.jeeshop.services.front.orderdetail.bean.Orderdetail;import net.jeeshop.services.front.orderdetail.dao.OrderdetailDao;import net.jeeshop.services.front.orderlog.bean.Orderlog;import net.jeeshop.services.front.orderlog.dao.OrderlogDao;import net.jeeshop.services.front.orderpay.bean.Orderpay;import net.jeeshop.services.front.orderpay.dao.OrderpayDao;import net.jeeshop.services.front.ordership.bean.Ordership;import net.jeeshop.services.front.ordership.dao.OrdershipDao;import net.jeeshop.services.front.product.bean.Product;import net.jeeshop.services.front.product.bean.ProductStockInfo;import net.jeeshop.services.front.product.dao.ProductDao;@Servicepublic class OrderServiceImpl extends ServersManager<Order, OrderDao> implements		OrderService {	private static final org.slf4j.Logger logger = LoggerFactory			.getLogger(OrderServiceImpl.class);    @Autowired    @Override    public void setDao(OrderDao orderDao) {        this.dao = orderDao;    }    @Autowired	private OrderdetailDao orderdetailDao;    @Autowired	private OrderpayDao orderpayDao;    @Autowired	private OrdershipDao ordershipDao;    @Autowired	private OrderlogDao orderlogDao;    @Autowired	private ProductDao productDao;    @Autowired	private AccountService accountService;	public void setAccountService(AccountService accountService) {		this.accountService = accountService;	}	public void setProductDao(ProductDao productDao) {		this.productDao = productDao;	}	public void setOrderpayDao(OrderpayDao orderpayDao) {		this.orderpayDao = orderpayDao;	}	public void setOrderlogDao(OrderlogDao orderlogDao) {		this.orderlogDao = orderlogDao;	}	public void setOrdershipDao(OrdershipDao ordershipDao) {		this.ordershipDao = ordershipDao;	}	public void setOrderdetailDao(OrderdetailDao orderdetailDao) {		this.orderdetailDao = orderdetailDao;	}	public boolean createOrder(Order order, List<Orderdetail> orderdetailList,Ordership ordership)			throws Exception {		if(order==null || orderdetailList==null || orderdetailList.size()==0 || ordership==null){			throw new NullPointerException("参数不能为空！");		}				//对商品进行砍库存，并同步内存中的库存数据//		if(!no){//			//如果检查没有出现库存不足的情况，则进行砍库存操作//			for (int i = 0; i < cartInfo.getProductList().size(); i++) {//				Product product = cartInfo.getProductList().get(i);//				ProductStockInfo stockInfo = SystemManager.productStockMap.get(product.getId());//				stockInfo.setStock(stockInfo.getStock() - product.getBuyCount());//				stockInfo.setChangeStock(true);//				SystemManager.productStockMap.put(product.getId(),stockInfo);//			}//		}				//创建订单		int orderID = dao.insert(order);		logger.debug("orderID=" + orderID);				//创建订单项		for (int i = 0; i < orderdetailList.size(); i++) {			Orderdetail orderdetail = orderdetailList.get(i);			orderdetail.setOrderID(orderID);			orderdetailDao.insert(orderdetail);		}				//创建支付记录对象		Orderpay orderpay = new Orderpay();		orderpay.setOrderid(order.getId());		orderpay.setPaystatus(Orderpay.orderpay_paystatus_n);		orderpay.setPayamount(Double.valueOf(order.getAmount()));		orderpay.setPaymethod(Orderpay.orderpay_paymethod_alipayescow);		int orderpayID = orderpayDao.insert(orderpay);		logger.error("orderpayID="+orderpayID);		order.setOrderpayID(String.valueOf(orderpayID));				//记录配送信息		ordership.setOrderid(String.valueOf(orderID));		ordershipDao.insert(ordership);				//记录订单创建日志		Orderlog orderlog = new Orderlog();		orderlog.setOrderid(String.valueOf(orderID));		orderlog.setAccount(order.getAccount());		orderlog.setContent("【创建订单】用户创建订单。订单总金额："+order.getAmount());		orderlog.setAccountType(Orderlog.orderlog_accountType_w);		orderlogDao.insert(orderlog);		return true;	}	@Override	public List<Order> selectOrderInfo(Order order) {		return dao.selectOrderInfo(order);	}//	@Override//	public boolean updateOrderStatus(Order order) {//		if(order==null){//			throw new NullPointerException("参数不能为空！");//		}////		Orderpay orderpay = orderpayDao.selectById(order.getOrderpayID());//		if(orderpay==null){//			throw new NullPointerException("根据支付记录号查询不到支付记录信息！");//		}//		String orderid = orderpay.getOrderid();//订单ID//		//		//更新支付记录为成功支付//		Orderpay orderpay2 = new Orderpay();//		orderpay2.setId(order.getOrderpayID());//		orderpay2.setTradeNo(order.getTradeNo());//		orderpay2.setPaystatus(Orderpay.orderpay_paystatus_y);//		orderpayDao.update(orderpay2);//		//		//更新订单的支付状态为成功支付//		order.setId(orderid);//		order.setPaystatus(Order.order_paystatus_y);//		dao.update(order);//		return true;//	}		@Override	@Transactional	public boolean alipayNotify(String trade_status,String refund_status,String out_trade_no,String trade_no,			String total_amount,String seller_id,String app_id) {		try {			return alipayNotify0(trade_status, refund_status, out_trade_no, trade_no					,total_amount,seller_id,app_id);		} catch (Exception e) {			logger.error(">>>alipayNotify...Exception..");			e.printStackTrace();			return false;		}	}		private boolean alipayNotify0(String trade_status,String refund_status,String out_trade_no,String trade_no,			String total_amount,String seller_id,String app_id) {		//1、商户需要验证该通知数据中的out_trade_no是否为商户系统中创建的订单号，		//2、判断total_amount是否确实为该订单的实际金额（即商户订单创建时的金额），		//3、校验通知中的seller_id（或者seller_email) 是否为out_trade_no这笔单据的对应的操作方		//（有的时候，一个商户可能有多个seller_id/seller_email），		//4、验证app_id是否为该商户本身。上述1、2、3、4有任何一个验证不通过，则表明本次通知是异常通知，务必忽略。		//在上述验证通过后商户必须根据支付宝不同类型的业务通知，正确的进行不同的业务处理，并且过滤重复的通知结果数据。		//在支付宝的业务通知中，只有交易通知状态为TRADE_SUCCESS或TRADE_FINISHED时，支付宝才会认定为买家付款成功。		synchronized (FrontContainer.alipay_notify_lock) {			logger.info("trade_status = " + trade_status + ",refund_status = " + refund_status + ",out_trade_no = " + out_trade_no + ",trade_no = " + trade_no);			if ((StringUtils.isBlank(trade_status)					&& StringUtils.isBlank(refund_status)) || (StringUtils.isBlank(out_trade_no)							&& StringUtils.isBlank(trade_no))) {				logger.error("请求非法!");				return false;			}			String orderpayID = null;			if(out_trade_no.startsWith("test")){				//此处做一个说明,localhost或127.0.0.1下的订单的请求发给支付宝的商户订单号都是test开头的，正式的都是非test开头的。				//可以参见OrdersAction.createPayInfo()方法。				orderpayID = out_trade_no.substring(4);			}else{				orderpayID = out_trade_no;			}			logger.info("orderpayID = " + orderpayID);			Orderpay orderpay = orderpayDao.selectById(orderpayID);			if(orderpay==null){				logger.error("根据支付记录号查询不到支付记录信息！");				return false;			}						String orderid = orderpay.getOrderid();//订单ID			Order order = dao.selectById(orderid);			if(order==null){				logger.error("根据订单号查询不到订单信息，orderid={}",orderid);				return false;			}			if(!order.getAmount().equals(total_amount)					||!AlipaynewConfig.APPID.equals(app_id)					||!systemManager.getAlipaySellerId().equals(seller_id)){				logger.error("参数与系统中的对应不上!");				return false;			}			String content = null;						if(StringUtils.isNotBlank(refund_status)){				/**				 * 退款流程				 */				if(refund_status.equals("WAIT_SELLER_AGREE")){//等待卖家同意退款	==>卖家需处理					content = "【支付宝异步通知-->退款流程】等待卖家同意退款(WAIT_SELLER_AGREE)。";									}else if(refund_status.equals("WAIT_BUYER_RETURN_GOODS")){//卖家同意退款，等待买家退货	==>通知买家退货，此 可以发站内信、短信、或邮件 通知对方					content = "【支付宝异步通知-->退款流程】退款协议达成，等待买家退货(WAIT_BUYER_RETURN_GOODS)。";									}else if(refund_status.equals("WAIT_SELLER_CONFIRM_GOODS")){//买家已退货，等待卖家收到退货	==>支付宝会通知卖家					content = "【支付宝异步通知-->退款流程】等待卖家收货(WAIT_SELLER_CONFIRM_GOODS)。";									}else if(refund_status.equals("REFUND_SUCCESS")){//卖家收到退货，退款成功，交易关闭	==>卖家登陆支付宝，确认OK。					//http://club.alipay.com/simple/?t9978565.html					content = "【支付宝异步通知-->退款流程】退款成功(REFUND_SUCCESS)。";									}else if(refund_status.equals("REFUND_CLOSED")){//卖家收到退货，退款成功，交易关闭	==>卖家登陆支付宝，确认OK。					//http://club.alipay.com/simple/?t9978565.html					content = "【支付宝异步通知-->退款流程】退款关闭(REFUND_CLOSED)。";									}else if(refund_status.equals("SELLER_REFUSE_BUYER")){//卖家收到退货，退款成功，交易关闭	==>卖家登陆支付宝，确认OK。					//http://club.alipay.com/simple/?t9978565.html					content = "【支付宝异步通知-->退款流程】卖家不同意协议，等待买家修改(SELLER_REFUSE_BUYER)。";				}				else{					//一般不会出现					content = "【支付宝异步通知-->退款流程】未知。refund_status = " + refund_status;				}				updateRefundStatus(orderid, refund_status);			}else if(StringUtils.isNotBlank(trade_status)){				/**				 * 交易流程				 */				if(trade_status.equals("WAIT_BUYER_PAY")){//等待买家付款					content = "【支付宝异步通知】等待买家付款(WAIT_BUYER_PAY)。";									}else if(trade_status.equals("TRADE_SUCCESS")){//已付款					if(orderpay.getPaystatus().equals(Orderpay.orderpay_paystatus_y)){						//由于支付宝的同步通知、异步通知，那么WAIT_SELLER_SEND_GOODS的时候会有2次通知，所以需要synchronized处理好,保证订单状态和日志的一致性。						return true;					}										content = "【支付宝异步通知】已付款。";										//更新支付记录为【成功支付】					Orderpay orderpay2 = new Orderpay();					orderpay2.setId(orderpayID);					orderpay2.setTradeNo(trade_no);					orderpay2.setPaystatus(Orderpay.orderpay_paystatus_y);					orderpayDao.update(orderpay2);										/**					 * 真实砍库存，并同步减少内容库存数					 */					logger.error("真实砍库存，并同步减少内容库存数...");					Orderdetail orderdetail = new Orderdetail();					orderdetail.setOrderID(Integer.valueOf(orderid));					List<Orderdetail> orderdetailList = orderdetailDao.selectList(orderdetail);					logger.error("orderdetailList = " + orderdetailList.size());					String lowStocks = null;//订单是否缺货记录//					int score = 0;//商品积分汇总					for (int i = 0; i < orderdetailList.size(); i++) {						Orderdetail detailInfo = orderdetailList.get(i);						String productID = String.valueOf(detailInfo.getProductID());						//内存砍库存呢						ProductStockInfo stockInfo = SystemManager.getInstance().getProductStockMap().get(productID);						if(stockInfo.getStock() >= detailInfo.getNumber()){							stockInfo.setStock(stockInfo.getStock() - detailInfo.getNumber());							stockInfo.setChangeStock(true);							//数据库砍库存							Product product = new Product();							product.setId(productID);							product.setStock(stockInfo.getStock());							product.setAddSellcount(detailInfo.getNumber());//增加销量							productDao.updateStockAfterPaySuccess(product);						}else{							lowStocks = Order.order_lowStocks_y;							//记录库存不足							Orderdetail od = new Orderdetail();							od.setId(detailInfo.getId());							od.setLowStocks(Orderdetail.orderdetail_lowstocks_y);							orderdetailDao.update(od);						}//						score += stockInfo.getScore();						logger.error("productID = " + productID + ",stockInfo.getStock() = " + stockInfo.getStock());//						SystemManager.productStockMap.put(product.getId(),stockInfo);					}										//更新订单的支付状态为【已支付】					Order _order = new Order();					_order.setId(orderid);					if (lowStocks != null) {						_order.setLowStocks(Order.order_lowStocks_y);					}					_order.setPaystatus(Order.order_paystatus_y);					dao.update(_order);									}else if(trade_status.equals("TRADE_FINISHED")){//交易完成					content = "【支付宝异步通知】交易完成(TRADE_FINISHED)。";															//订单结束后，订单上面赠送的积分都成功转移到用户账户上。					Account acc = new Account();					acc.setAccount(order.getAccount());					acc.setAddScore(order.getScore() - order.getAmountExchangeScore());//支付完成，扣除订单消耗的积分					accountService.updateScore(acc);										//更新订单状态为【已签收】					Order _order = new Order();					_order.setId(orderid);					_order.setStatus(Order.order_status_sign);					dao.update(_order);				}else{					//一般不会出现					content = "【支付宝异步通知】未知。trade_status = " + trade_status;				}			}else{				throw new RuntimeException("运行异常!");			}						/**			 * 以上代码,如不可以返回都会走到此处,记录下日志.			 */			insertOrderlog(orderid, content);						return true;		}	}		/**	 * 更新订单的退款状态	 * @param orderid	订单ID	 * @param refundStatus	退款状态	 */	private void updateRefundStatus(String orderid,String refundStatus){		Order order = new Order();		order.setId(orderid);		order.setRefundStatus(refundStatus);		dao.update(order);	}		/**	 * 插入订单操作日志	 * @param orderid	订单ID	 * @param content	日志内容	 */	private void insertOrderlog(String orderid,String content) {		Orderlog orderlog = new Orderlog();		orderlog.setOrderid(orderid);//订单ID		orderlog.setAccount("alipay_notify");//操作人账号		orderlog.setContent(content);//日志内容		orderlog.setAccountType(Orderlog.orderlog_accountType_p);		orderlogDao.insert(orderlog);	}	@Override	public OrderSimpleReport selectOrdersSimpleReport(String account) {		return dao.selectOrdersSimpleReport(account);	}}