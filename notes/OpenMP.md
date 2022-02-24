# OpenMP

以前的处理器一般只有一个核，因此只能在一个核上顺序地执行指令。

但是现在地处理器一般有多核，同时还有多个处理器。因此我们想在一个处理器上把所有核都利用起来，同时并行地执行命令。





![image-20211217212834504](https://raw.githubusercontent.com/RogersLj/Image/master/PicGo/image-20211217212834504.png)

![image-20211217212845078](https://raw.githubusercontent.com/RogersLj/Image/master/PicGo/image-20211217212845078.png)



我们将并行执行指令的过程叫线程，同一个进程的线程之间共享同一个内存，



---

![image-20211217213114401](https://raw.githubusercontent.com/RogersLj/Image/master/PicGo/image-20211217213114401.png)

![image-20211217213121735](https://raw.githubusercontent.com/RogersLj/Image/master/PicGo/image-20211217213121735.png)

![image-20211217213128791](https://raw.githubusercontent.com/RogersLj/Image/master/PicGo/image-20211217213128791.png)

![image-20211217213152494](https://raw.githubusercontent.com/RogersLj/Image/master/PicGo/image-20211217213152494.png)



https://engineering.purdue.edu/~smidkiff/ece563/files/ECE563OpenMPTutorial.pdf



---

# lab08

## Exercise 1: OpenMP Hello World

![image-20211217221357652](https://raw.githubusercontent.com/RogersLj/Image/master/PicGo/image-20211217221357652.png)

