//
//  SocketUtility.h
//  MTBBarcodeScannerExample
//
//  Created by Cha YoungHoon on 5/27/16.
//
//

#import <UIKit/UIKit.h>
#import "NetworkDef.h"

#define BUF_SIZE    1024

@interface SocketUtility : UIViewController < UIAlertViewDelegate,UITableViewDataSource,UITableViewDelegate >
{
    /* System Settings */
    unsigned char Count1;
    BOOL _StopSearhFlag;
    BOOL parseBusyf;
    
    /* TCP IP ?§Ï†ï */
    // int tcpsock;
    struct sockaddr_in TAddr;
    
    /* UDP ?§Ï†ï */
    int Usock;
    struct sockaddr_in serv_addr,from_adr;
    socklen_t adr_sz;
    char message[BUF_SIZE];
    
    /* AVR ?§Ï†ï */
    NSString *_friendlyname;
    NSTimer *TimerMSearch;
    NSString *_deviceType;
    
    /* XML parsing Í¥Ä??*/
    NSMutableString *capturedCharacters;
    NSData *_XmlData;
    BOOL inItemElement;
    
    /* Alert View */
    NSTimer *TimerMSearchTimeOut;
    
    UIActivityIndicatorView *NetSearchCircle;
}

@property (retain) NSMutableData *responseData;
@property (retain) NSData *XmlData;
@property (atomic, retain)NSString *friendlyname;
//@property (strong, nonatomic) IBOutlet UITableView *UITable;
@property (atomic, assign) BOOL StopSearhFlag;
@property (atomic, retain)NSString *deviceType;
//@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *NetSearchCircle;

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

@end
