//
//  BackendProxy.m
//  Where is my friend?
//
//  Created by MacDev on 10/31/13.
//  Copyright (c) 2013 MacDev. All rights reserved.
//

#import "BackendProxy.h"
#import "Reachability.h"

NSString * server = @"testingpis.azurewebsites.net";

@implementation BackendProxy

+ (bool)internetConnection{
    
    //verifico conexion con el server
    Reachability *networkReachability = [Reachability reachabilityWithHostName:server];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    
    if (networkStatus == NotReachable){
        //si no hay conexion con el server
        return false;
    }
    
    return true;
}

+ (ServerResponse *)login :(NSString*)email :(NSString*)pswd :(NSString*)plat :(NSString*)device :(NSString*)idiom{

    //build an info object and convert to json
    NSDictionary* info = [NSDictionary dictionaryWithObjectsAndKeys:
                          email,@"Mail",
                          pswd, @"Password",
                          plat,@"Platform",
                          device,@"DeviceId",
                          idiom,@"Language",
                          nil];


    NSString * url = @"http://";
    NSString * url1 = [server copy];
    url = [url stringByAppendingString:url1];
    url = [url stringByAppendingString:@"/api/Users/LoginWhere/"];
    
    // POST
    NSMutableURLRequest *request = [NSMutableURLRequest
                                    requestWithURL:[NSURL URLWithString:url]];

    NSError *error;
    NSData *postData = [NSJSONSerialization dataWithJSONObject:info options:0 error:&error];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];
    //NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];

    // imprimo lo que mando para verificar
    //NSLog(@"%@", [[NSString alloc] initWithData:postData2 encoding:NSUTF8StringEncoding]);

    NSHTTPURLResponse* urlResponse = nil;
    error = [[NSError alloc] init];
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
    NSString *result = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];

    // imprimo el resultado del post para verificar
    //NSLog(@"Response: %@", result);
    //NSLog(@"Response: %ld", (long)urlResponse.statusCode);
    
    //comparo segun lo que me dio el status code para ver como sigo
    if ((long)urlResponse.statusCode == 200){
        
        //paso el NSData que devuelve el servidor a un NSDictionary para agarrar los datos del JSON
        NSError *jsonParsingError = nil;
        NSDictionary * data = [NSJSONSerialization JSONObjectWithData:responseData
                                                              options:0 error:&jsonParsingError];
        //agarro los datos del dictinary
        NSNumber* userIdInt = [data objectForKey:@"Id"];
        int userIdInt1 = [userIdInt intValue];
        
        NSString *userId = [NSString stringWithFormat:@"%d", userIdInt1];
        
        NSString * userName = [data objectForKey:@"Name"];
        NSString * userMail = [data objectForKey:@"Mail"];
        
        //me creo el objeto serverResponse
        ServerResponse * sr = [ServerResponse alloc];
        sr = [sr initialize :(NSInteger)urlResponse.statusCode :result :userId :userName : userMail];
        
        //GUARDO LA INFO DEL USUARIO
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:userId forKey:@"id"];
        [defaults setObject:userMail forKey:@"mail"];
        [defaults setObject:userName forKey:@"name"];
        
        return sr;
        
    }
    
    //me creo el objeto serverResponse cuando hubo error
    ServerResponse * sr = [ServerResponse alloc];
    sr = [sr initialize :(NSInteger)urlResponse.statusCode :NULL :NULL :NULL :NULL];
    
    return sr;
    
}

+ (ServerResponse *)send :(NSString*)to{
    
    //creo el JSON
    NSString * from=[[NSUserDefaults standardUserDefaults]stringForKey:@"id"];
    
    NSDictionary* info = [NSDictionary dictionaryWithObjectsAndKeys:
                          from,@"IdFrom",
                          to, @"IdTo",
                          nil];
    
    NSString * url = @"http://";
    NSString * url1 = [server copy];
    url = [url stringByAppendingString:url1];
    url = [url stringByAppendingString:@"/api/Solicitudes/Send/"];
    
    // POST
    NSMutableURLRequest *request = [NSMutableURLRequest
                                    requestWithURL:[NSURL URLWithString:url]];
    
    NSError *error;
    NSData *postData2 = [NSJSONSerialization dataWithJSONObject:info options:0 error:&error];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData2];
    
    NSHTTPURLResponse* urlResponse = nil;
    error = [[NSError alloc] init];
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
    //NSString *result = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    
    ServerResponse * sr = [ServerResponse alloc];
    sr = [sr initialize :(NSInteger)urlResponse.statusCode :NULL :NULL :NULL :NULL];
    
    return sr;
    
}

+ (void)logout{
    
    //creo el JSON
    NSString * mail=[[NSUserDefaults standardUserDefaults]stringForKey:@"mail"];
    
    NSDictionary* info = [NSDictionary dictionaryWithObjectsAndKeys:
                          mail,@"Mail",
                          nil];
    
    NSString * url = @"http://";
    NSString * url1 = server;
    url = [url stringByAppendingString:url1];
    url = [url stringByAppendingString:@"/api/Users/LogoutWhere/"];
    
    // POST
    NSMutableURLRequest *request = [NSMutableURLRequest
                                    requestWithURL:[NSURL URLWithString:url]];
    
    NSError *error;
    NSData *postData2 = [NSJSONSerialization dataWithJSONObject:info options:0 error:&error];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData2];
    
    NSHTTPURLResponse* urlResponse = nil;
    error = [[NSError alloc] init];
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];

}

+ (NSArray *)GetLastFriendsLocationsById{
    
    NSString *id = [[NSUserDefaults standardUserDefaults]stringForKey:@"id"];
    if (id){
        NSString * url = @"http://";
        NSString * url1 = [server copy];
        url = [url stringByAppendingString:url1];
        url = [url stringByAppendingString:@"/api/Geolocation/GetLastFriendsLocationsById/"];
        url = [url stringByAppendingString:id];
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL
                                                              URLWithString:url]];
        
        NSData *response = [NSURLConnection sendSynchronousRequest:request
                                                 returningResponse:nil error:nil];
        
        if (response){
            NSError *jsonParsingError = nil;
            NSArray * jsonFriends = [NSJSONSerialization JSONObjectWithData:response
                                                                    options:0 error:&jsonParsingError];
            
            return jsonFriends;

        }else
            return nil;
    }else{
        return nil;
    }
}

+ (NSArray *)GetAllFriends{
    NSString *id = [[NSUserDefaults standardUserDefaults]stringForKey:@"id"];
    
    NSString * url = @"http://";
    NSString * url1 = [server copy];
    url = [url stringByAppendingString:url1];
    url = [url stringByAppendingString:@"/api/Friends/GetAllFriends/"];
    url = [url stringByAppendingString:id];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL
                                                          URLWithString:url]];
    
    
    NSData *response = [NSURLConnection sendSynchronousRequest:request
                                             returningResponse:nil error:nil];
    if (response){
        NSError *jsonParsingError = nil;
        NSArray * jsonData = [NSJSONSerialization JSONObjectWithData:response
                                                   options:0 error:&jsonParsingError];

        return jsonData;
    }else
        return nil;
}

+ (NSArray *)GetAll{
    
    NSString *id = [[NSUserDefaults standardUserDefaults]stringForKey:@"id"];
    
    NSString * url = @"http://";
    NSString * url1 = [server copy];
    url = [url stringByAppendingString:url1];
    url = [url stringByAppendingString:@"/api/Solicitudes/GetAll/"];
    url = [url stringByAppendingString:id];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL
                                                          URLWithString:url]];
    
    
    NSData *response = [NSURLConnection sendSynchronousRequest:request
                                             returningResponse:nil error:nil];
    
    if (response){
        NSError *jsonParsingError = nil;
        NSArray * jsonData = [NSJSONSerialization JSONObjectWithData:response
                                                   options:0 error:&jsonParsingError];
    
        return jsonData;
    }else
        return nil;
}

+ (void)Accept :(NSString *)idSol {
    
    //creo el JSON
    NSString * idUser =[[NSUserDefaults standardUserDefaults]stringForKey:@"id"];
    
    NSDictionary* info2 = [NSDictionary dictionaryWithObjectsAndKeys:
                           idUser,@"idUser",
                           idSol, @"idSolicitud",
                           nil];
    
    NSString * url = @"http://";
    NSString * url1 = [server copy];
    url = [url stringByAppendingString:url1];
    url = [url stringByAppendingString:@"/api/Solicitudes/Accept/"];
    
    NSMutableURLRequest *request2 = [NSMutableURLRequest
                                     requestWithURL:[NSURL URLWithString:url]];
    
    NSError *error;
    NSData *postData2 = [NSJSONSerialization dataWithJSONObject:info2 options:0 error:&error];
    [request2 setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request2 setHTTPMethod:@"POST"];
    [request2 setHTTPBody:postData2];
    //NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    // imprimo lo que mando para verificar
    NSLog(@"%@", [[NSString alloc] initWithData:postData2 encoding:NSUTF8StringEncoding]);
    
    NSHTTPURLResponse* urlResponse = nil;
    error = [[NSError alloc] init];
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request2 returningResponse:&urlResponse error:&error];
    NSString *result = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    
}

+ (void)Reject :(NSString *)idSol{
    
    //creo el JSON
    NSString * idUser =[[NSUserDefaults standardUserDefaults]stringForKey:@"id"];
    
    NSDictionary* info2 = [NSDictionary dictionaryWithObjectsAndKeys:
                           idUser,@"idUser",
                           idSol, @"idSolicitud",
                           nil];
    
    NSString * url = @"http://";
    NSString * url1 = [server copy];
    url = [url stringByAppendingString:url1];
    url = [url stringByAppendingString:@"/api/Solicitudes/Reject/"];
    
    NSMutableURLRequest *request2 = [NSMutableURLRequest
                                     requestWithURL:[NSURL URLWithString:url]];
    
    NSError *error;
    NSData *postData2 = [NSJSONSerialization dataWithJSONObject:info2 options:0 error:&error];
    [request2 setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request2 setHTTPMethod:@"POST"];
    [request2 setHTTPBody:postData2];
    //NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    // imprimo lo que mando para verificar
    NSLog(@"%@", [[NSString alloc] initWithData:postData2 encoding:NSUTF8StringEncoding]);
    
    NSHTTPURLResponse* urlResponse = nil;
    error = [[NSError alloc] init];
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request2 returningResponse:&urlResponse error:&error];
    NSString *result = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    
}

+ (void)resetBadgeCount{
    //creo el JSON
    NSString * mail=[[NSUserDefaults standardUserDefaults]stringForKey:@"mail"];
    
    NSDictionary* info = [NSDictionary dictionaryWithObjectsAndKeys:
                          mail,@"Mail",
                          nil];
    
    NSString * url = @"http://";
    NSString * url1 = [server copy];
    url = [url stringByAppendingString:url1];
    url = [url stringByAppendingString:@"/api/Users/ResetBadge/"];
    
    // POST
    NSMutableURLRequest *request = [NSMutableURLRequest
                                    requestWithURL:[NSURL URLWithString:url]];
    
    NSError *error;
    NSData *postData2 = [NSJSONSerialization dataWithJSONObject:info options:0 error:&error];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData2];
    
    NSHTTPURLResponse* urlResponse = nil;
    error = [[NSError alloc] init];
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];

}

+ (void)setLocation :(NSString *)longit :(NSString *)latit{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *email = [defaults stringForKey:@"mail"];
    NSString *nom = [defaults stringForKey:@"name"];
    
    
    
    NSDictionary* info2 = [NSDictionary dictionaryWithObjectsAndKeys:
                           email,@"Mail",
                           nom,@"Name",
                           latit, @"Latitude",
                           longit, @"Longitude",
                           nil];
    
    NSString * url = @"http://";
    NSString * url1 = [server copy];
    url = [url stringByAppendingString:url1];
    url = [url stringByAppendingString:@"/api/Geolocation/SetLocation/"];
    
    // POST
    NSMutableURLRequest *request2 = [NSMutableURLRequest
                                     requestWithURL:[NSURL URLWithString:url]];
    
    NSError *error;
    NSData *postData2 = [NSJSONSerialization dataWithJSONObject:info2 options:0 error:&error];
    [request2 setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request2 setHTTPMethod:@"POST"];
    [request2 setHTTPBody:postData2];
    //NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    // imprimo lo que mando para verificar
    NSLog(@"%@", [[NSString alloc] initWithData:postData2 encoding:NSUTF8StringEncoding]);
    
    NSHTTPURLResponse* urlResponse = nil;
    error = [[NSError alloc] init];
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request2 returningResponse:&urlResponse error:&error];
    //NSString *result = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    
    // imprimo el resultado del post para verificar
    //NSLog(@"Response: %@", result);
    //NSLog(@"Response: %ld", (long)urlResponse.statusCode);
}


@end