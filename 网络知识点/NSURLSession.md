#### NSURLSession
三种类型
NSURLSessionConfiguration分为三种类型：

`defaultSessionConfiguration` 默认session配置，类似 NSURLConnection 的标准配置，使用硬盘来存储缓存数据。   
`ephemeralSessionConfiguration` 临时session配置，与默认配置相比，这个配置不会将缓存、cookie等存在本地，只会存在内存里，所以当程序退出时，所有的数据都会消失。
`backgroundSessionConfiguration` 后台session配置，与默认配置类似，不同的是会在后台开启另一个线程来处理网络数据。   
除了默认的配置类型 NSURLSessionConfiguration 还有很多参数可以设置来配置不同的网络需求。比如设置缓存URLCache：   


`NSURLSessionTask`

NSURLSession 需要使用 NSURLSessionTask 来具体执行网络请求的任务。 NSURLSessionTask 支持网络请求的取消、暂停和恢复，比如下载文件暂停之后再恢复就能够自动从上次的进度继续下载。NSURLSessionTask 也能获取数据的读取进度。

NSURLSessionTask 也分为三类：

NSURLSessionDataTask 处理一般的 NSData 数据对象，比如通过GET或POST方式从服务器获取JSON或XML返回等等，但不支持后台获取。
NSURLSessionUploadTask 用于上传文件，支持后台上传。
NSURLSessionDownloadTask 用于下载文件，支持后台下载。
所以一般没有特殊需求并不用直接使用 NSURLSessionTask 。