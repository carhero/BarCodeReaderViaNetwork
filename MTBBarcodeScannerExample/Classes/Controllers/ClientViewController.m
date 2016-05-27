//
//  ClientViewController.m
//  MTBBarcodeScannerExample
//
//  Created by Cha YoungHoon on 5/26/16.
//
//

#import "ClientViewController.h"

/* BSSID for user indivisual device */
#import <NetworkExtension/NetworkExtension.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import "Reachability.h"

#define MODEL_NAME    "PW1x00"
#define MSEARCH_IP    "239.255.255.250"
#define MSEARCH_PORT  "12345"

//NSString *GTargetIP;
int tcpsock;
BOOL IsTcpAvailable;

@interface ClientViewController ()
{
    NSString *_CurrentIP;
    NSString *_CurrentUrl;
    NetworkStatus network_status;
}
@end

@implementation ClientViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"ClientViewController-viewDidLoad");
    
    // Init routine & variable

    
    // Check wifi or not
    network_status = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
    
    switch (network_status)
    {
        case ReachableViaWiFi:
#if DEBUG_MSG
            NSLog(@"Connected WiFi");
#endif
            break;
        case NotReachable:
        case ReachableViaWWAN:
        default:
            NSLog(@"Not connected WiFi");
            UIAlertView *NetAlert = [[UIAlertView alloc] initWithTitle:@"Connection Problem"
                                                               message:@"There is a problem connecting to your home network."
                                                              delegate:nil
                                                     cancelButtonTitle:@"OK"
                                                     otherButtonTitles:nil];
            
            [self.ActivityIndicator stopAnimating];
            [NetAlert show];
            return;
            break;
    }
    
    // UDP enter routine should be here
    [self TimerMSearchDataSend];
    [self MSearchMessageDataSend];
    [NSThread detachNewThreadSelector:@selector(GetMsearchMsgData) toTarget:self withObject:nil];
    [self enablethread];
    
    //?짠횑채??책횑횇짢 ??왗띯돞???챦횕첫??WWAN, WiFi
    network_status = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
    
    /* TCP IP READ DATA test */
    [NSThread detachNewThreadSelector:@selector(GetMsearchMsgData) toTarget:self withObject:nil];
}


-(void)disablethread {
    
    if (self.TimerMSearchTimeOut != nil) {
        [TimerMSearchTimeOut invalidate];
    }
    
    [self.ActivityIndicator stopAnimating];
}

-(void)enablethread {
#if DEBUG_MSG
    NSLog(@"enablethread");
#endif
    
    [self.ActivityIndicator startAnimating];
    
    TimerMSearch = [NSTimer scheduledTimerWithTimeInterval:2.0
                                                    target:self
                                                  selector:@selector(TimerMSearchDataSend)
                                                  userInfo:nil
                                                   repeats:YES];
    
    
//    TimerMSearchTimeOut = [NSTimer scheduledTimerWithTimeInterval:30.0
//                                                           target:self
//                                                         selector:@selector(alert:)
//                                                         userInfo:nil
//                                                          repeats:NO];
}


-(void)TimerMSearchDataSend {
    const char Buf1[] = MODEL_NAME;
    
#if DEBUG_MSG
    NSLog(@"TimerMSearchDataSend");
#endif
    sendto(Usock, Buf1, sizeof(Buf1), 0, (struct sockaddr*)&serv_addr, sizeof(serv_addr));
//    sendto(Usock, Buf2, sizeof(Buf2), 0, (struct sockaddr*)&serv_addr, sizeof(serv_addr));
}

-(void)MSearchMessageDataSend
{
    const char Buf1[] = MODEL_NAME;
    
    Usock = socket(PF_INET, SOCK_DGRAM, 0);
    if(Usock==-1) {
        NSLog(@"socket() error");
        return;
    }
    memset(&serv_addr, 0, sizeof(serv_addr));
    serv_addr.sin_family=AF_INET;
    serv_addr.sin_addr.s_addr=inet_addr(MSEARCH_IP);
    serv_addr.sin_port=htons(atoi(MSEARCH_PORT));
    
    sendto(Usock, Buf1, sizeof(Buf1), 0, (struct sockaddr*)&serv_addr, sizeof(serv_addr));
//    sendto(Usock, Buf2, sizeof(Buf2), 0, (struct sockaddr*)&serv_addr, sizeof(serv_addr));
    //    [TimerMSearch invalidate];
}

#if 0
-(BOOL)CompareStr:(char *)src destine:(char *)dst lenth:(int)len {
    
    BOOL ret = FALSE;
    int i = 0;
    for(i = 0; i < len; i++) {
        if(src[i] != dst[i]) {
            break;
        }
    }
    if(i == len-1) {
        ret = YES;
    }
    return ret;
}
#endif
-(NSString *)getDeviceURL:(char *)Buf {
    
    int uCnt1 = 0;
    char tempbuf[1000] = {0};
    
    if(Buf != NULL)
    {
        for(uCnt1 = 0; uCnt1 < 1000;uCnt1++) {
            if (Buf[uCnt1] == '\r') {
                break;
            }
            tempbuf[uCnt1] = Buf[uCnt1];
        }
    }
    return [NSString stringWithUTF8String:tempbuf];
}

-(NSString *)getNetworkUrlFromMsearchBuf:(char *)Buf {
    
    char *strptr = NULL;
    strptr = strstr(Buf, "http://");
    
    return [self getDeviceURL:strptr];
}


#pragma - mark - GET MSEARCH DATA -
-(void) GetMsearchMsgData {

//    int ret = 0;
//    _fParseReq = TRUE;
//    _uParseCnt = 0;
//#if DEBUG_MSG
//    NSLog(@"Thread1 UDP Recv Start");
//#endif
//    while (1)
//    {
//        if(self.StopSearhFlag) {
//            break;
//        }
//        adr_sz = sizeof(from_adr);
//        ret = recvfrom(Usock, message, BUF_SIZE, 0,(struct sockaddr*)&from_adr, &adr_sz);
//#if DEBUG_MSG
//        NSLog(@"ret value = %d",ret);
//        printf("%s\n",message);
//#endif
//        /* 새로운 URL 을 체크하여 Buf에 답는 루틴 */
//        _CurrentUrl = [self getNetworkUrlFromMsearchBuf:message];
//        if([self isPushableUrlToBufWithUrl:_CurrentUrl]) {
//            [_loopIPBuf insertObject:_CurrentUrl atIndex:_loopIPBuf.count];
//#if DEBUG_MSG
//            NSLog(@"new url saved..");
//            NSLog(@"_loopIPBuf.count = %lu",(unsigned long)_loopIPBuf.count);
//#endif
//        }
//        
//        /* parseing request */
//        if(_uParseCnt < _loopIPBuf.count) {
//#if DEBUG_MSG
//            NSLog(@"_loopIPBuf.count = %lu",(unsigned long)_loopIPBuf.count);
//            NSLog(@"parseing request-_uParseCnt = %ld",(long)_uParseCnt);
//#endif
//            if(_fParseReq) {
//                _fParseReq = FALSE;
//                [self GetDataFromAvrWithSSDPDataWithURL:[_loopIPBuf objectAtIndex:_uParseCnt]];
//            }
//        }
//        
//        memset(message, 0, BUF_SIZE);
//        adr_sz = 0;
//    }
}


// ------------------------------------------------------------
// API (If wifi is connected)
// ------------------------------------------------------------
- (id)fetchSSIDInfo {
    NSArray *ifs = (__bridge_transfer NSArray *)CNCopySupportedInterfaces();
    NSLog(@"Supported interfaces: %@", ifs);
    NSDictionary *info;
    for (NSString *ifnam in ifs) {
        info = (__bridge_transfer NSDictionary *)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        NSLog(@"%@ => %@", ifnam, info);
        if (info && [info count]) { break; }
    }
    return info;
}


// ------------------------------------------------------------
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
