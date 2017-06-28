# ObjectiveC-Demo-code

For calling a API in objective C I have created my Wrapper class which is Enhacnced from the AFnetworking Library. My wrapper class is handle the every REST method of POST,GET,PUT,DELETE and Multipart request as well.

Here I have provided only one View controller which is used my wrapper calss method 

    -(void)requestWithURL:(NSString*)apiName data:(NSDictionary*)dictParams withType:(NSString *)methodType withCompletion:(ManagerCompletionBlock)pCompletionBlock

