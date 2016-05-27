//
//  MTBAdvancedExampleViewController.h
//  MTBBarcodeScannerExample
//
//  Created by Mike Buss on 2/10/14.
//
//

#import <UIKit/UIKit.h>
#import "NetworkDef.h"

@interface MTBAdvancedExampleViewController : UIViewController
{
    //    TCP IP
    struct sockaddr_in TAddr;
    //    UDP
    int Usock;
    struct sockaddr_in serv_addr,from_adr;
    socklen_t adr_sz;
    
    NSString *CtrlPageIP;
}
@end
