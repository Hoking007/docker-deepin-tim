# docker-deepin-tim

基于 Docker 封装的 Deepin-TIM，开箱即用。

在 ygcaicn 以及 bestwu 封装的基础上，解决高分屏显示问题。

默认 DPI=120，如果有需要可在 “tim.sh” 中修改，例如 “140”：

```sh
-e DPI=140
```

## 1, 构建 Docker 镜像，只需要构建一次

```sh
./build.sh
```

## 2, 构建并启动 Docker 容器

```sh
./tim.sh
```

## 3, 用户数据

```sh
/home/$(whoami)/TencentFiles
```

## 4, Docker hub images

<https://hub.docker.com/repository/docker/hoking007/tim>

## 感谢

<https://github.com/ygcaicn/ubuntu_qq>

<https://github.com/bestwu/docker-qq>

<https://github.com/bestwu/docker-wechat>
