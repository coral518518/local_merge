const { exec } = require('child_process');
const path = require('path');
const fs = require('fs');

// 定义要扫描的根目录
const projectsDirectory = './projects'; // 假设所有项目都在 `projects` 文件夹下

// 扫描项目文件夹并查找 Dockerfile
fs.readdir(projectsDirectory, (err, files) => {
    if (err) {
        console.error('读取目录失败:', err);
        return;
    }

    // 遍历所有项目文件夹
    files.forEach((folder) => {
        const projectPath = path.join(projectsDirectory, folder);

        // 检查该文件夹下是否有 Dockerfile
        fs.stat(path.join(projectPath, 'Dockerfile'), (err, stats) => {
            if (err || !stats.isFile()) {
                console.log(`项目 ${folder} 没有找到 Dockerfile，跳过`);
                return;
            }

            // 构建 Docker 镜像
            const imageName = `my_${folder}_image`; // 给每个项目命名一个镜像
            exec(`docker build -t ${imageName} ${projectPath}`, (err, stdout, stderr) => {
                if (err) {
                    console.error(`构建 ${folder} 镜像失败:`, stderr);
                    return;
                }

                console.log(`项目 ${folder} 镜像构建成功`);

                // 启动容器，假设每个容器使用不同端口
                const port = 3000 + Object.keys(files).indexOf(folder);
                exec(`docker run -d -p ${port}:80 ${imageName}`, (err, stdout, stderr) => {
                    if (err) {
                        console.error(`启动 ${folder} 容器失败:`, stderr);
                        return;
                    }

                    console.log(`项目 ${folder} 容器已启动，映射端口 ${port}`);
                });
            });
        });
    });
});