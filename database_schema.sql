-- ========================================
-- 学管平台数据库创建脚本
-- 数据库: xueguan_platform
-- 创建时间: 2024
-- ========================================

-- 创建数据库
CREATE DATABASE IF NOT EXISTS xueguan_platform DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE xueguan_platform;

-- ========================================
-- 1. 基础用户模块
-- ========================================

-- 用户表
CREATE TABLE IF NOT EXISTS sys_user (
    id BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
    username VARCHAR(50) NOT NULL COMMENT '用户名/工号/学号',
    password VARCHAR(100) NOT NULL COMMENT '加密密码',
    role ENUM('ADMIN', 'TEACHER', 'STUDENT') NOT NULL COMMENT '角色',
    status TINYINT NOT NULL DEFAULT 1 COMMENT '状态 (1 正常, 0 禁用)',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (id),
    UNIQUE KEY uk_username (username)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='用户表';

-- 学生扩展表
CREATE TABLE IF NOT EXISTS base_student (
    id BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
    user_id BIGINT NOT NULL COMMENT '关联用户表',
    student_no VARCHAR(20) NOT NULL COMMENT '学号',
    name VARCHAR(50) NOT NULL COMMENT '姓名',
    class_name VARCHAR(50) COMMENT '班级',
    department VARCHAR(50) COMMENT '系别',
    grade VARCHAR(10) COMMENT '年级',
    PRIMARY KEY (id),
    UNIQUE KEY uk_student_no (student_no),
    KEY idx_user_id (user_id),
    CONSTRAINT fk_student_user FOREIGN KEY (user_id) REFERENCES sys_user(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='学生扩展表';

-- 教师扩展表
CREATE TABLE IF NOT EXISTS base_teacher (
    id BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
    user_id BIGINT NOT NULL COMMENT '关联用户表',
    teacher_no VARCHAR(20) NOT NULL COMMENT '工号',
    name VARCHAR(50) NOT NULL COMMENT '姓名',
    title VARCHAR(50) COMMENT '职称',
    department VARCHAR(50) COMMENT '所属系',
    PRIMARY KEY (id),
    UNIQUE KEY uk_teacher_no (teacher_no),
    KEY idx_user_id (user_id),
    CONSTRAINT fk_teacher_user FOREIGN KEY (user_id) REFERENCES sys_user(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='教师扩展表';

-- ========================================
-- 2. 教学管理模块
-- ========================================

-- 课程表
CREATE TABLE IF NOT EXISTS teach_course (
    id BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
    course_no VARCHAR(20) NOT NULL COMMENT '课程编号',
    course_name VARCHAR(100) NOT NULL COMMENT '课程名称',
    teacher_id BIGINT NOT NULL COMMENT '任课教师ID',
    semester VARCHAR(20) NOT NULL COMMENT '学期 (如: 2023-2024-1)',
    credits DECIMAL(3,1) NOT NULL COMMENT '学分',
    PRIMARY KEY (id),
    UNIQUE KEY uk_course_no_semester (course_no, semester),
    KEY idx_teacher_id (teacher_id),
    CONSTRAINT fk_course_teacher FOREIGN KEY (teacher_id) REFERENCES base_teacher(id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='课程表';

-- ========================================
-- 3. 科研与竞赛模块
-- ========================================

-- 竞赛获奖表
CREATE TABLE IF NOT EXISTS res_competition (
    id BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
    participant_id BIGINT NOT NULL COMMENT '参与者ID (学生或教师)',
    participant_type ENUM('STUDENT', 'TEACHER') NOT NULL COMMENT '参与者类型',
    comp_name VARCHAR(100) NOT NULL COMMENT '竞赛名称 (如: 蓝桥杯)',
    level VARCHAR(20) NOT NULL COMMENT '级别 (国赛/省赛)',
    award_grade VARCHAR(20) NOT NULL COMMENT '奖项等级 (一等奖/二等奖等)',
    data_source VARCHAR(20) NOT NULL COMMENT '数据来源 (学院统计/学校下发)',
    award_date DATE NOT NULL COMMENT '获奖日期',
    remark VARCHAR(255) COMMENT '备注',
    PRIMARY KEY (id),
    KEY idx_participant (participant_id, participant_type),
    KEY idx_award_date (award_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='竞赛获奖表';

-- 大创项目表
CREATE TABLE IF NOT EXISTS res_innovation (
    id BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
    project_no VARCHAR(30) NOT NULL COMMENT '项目编号',
    project_name VARCHAR(100) NOT NULL COMMENT '项目名称',
    leader_id BIGINT NOT NULL COMMENT '负责人ID',
    level VARCHAR(20) NOT NULL COMMENT '级别 (国家级/省级/校级)',
    status VARCHAR(20) NOT NULL COMMENT '状态 (立项/进行中/结题)',
    funding DECIMAL(10,2) NOT NULL COMMENT '经费',
    start_date DATE NOT NULL COMMENT '开始日期',
    end_date DATE NOT NULL COMMENT '结束日期',
    PRIMARY KEY (id),
    UNIQUE KEY uk_project_no (project_no),
    KEY idx_leader_id (leader_id),
    KEY idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='大创项目表';

-- 论文发表表
CREATE TABLE IF NOT EXISTS res_paper (
    id BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
    author_id BIGINT NOT NULL COMMENT '作者ID',
    title VARCHAR(200) NOT NULL COMMENT '论文标题',
    journal_name VARCHAR(100) NOT NULL COMMENT '期刊名称',
    publish_date DATE NOT NULL COMMENT '发表时间',
    index_type VARCHAR(20) NOT NULL COMMENT '收录类型 (SCI/EI/CORE等)',
    remark VARCHAR(255) COMMENT '备注',
    PRIMARY KEY (id),
    KEY idx_author_id (author_id),
    KEY idx_publish_date (publish_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='论文发表表';

-- 科研项目表
CREATE TABLE IF NOT EXISTS res_project (
    id BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
    project_name VARCHAR(100) NOT NULL COMMENT '项目名称',
    principal_id BIGINT NOT NULL COMMENT '负责人ID',
    source VARCHAR(50) NOT NULL COMMENT '来源 (横向/纵向)',
    amount DECIMAL(12,2) NOT NULL COMMENT '项目金额',
    start_date DATE NOT NULL COMMENT '起止时间',
    end_date DATE NOT NULL,
    PRIMARY KEY (id),
    KEY idx_principal_id (principal_id),
    KEY idx_source (source)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='科研项目表';

-- 教研/科研奖励表
CREATE TABLE IF NOT EXISTS res_award (
    id BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
    recipient_id BIGINT NOT NULL COMMENT '获得者ID',
    award_name VARCHAR(100) NOT NULL COMMENT '奖励名称',
    award_type ENUM('TEACHING', 'RESEARCH') NOT NULL COMMENT '类型 (教研/科研)',
    level VARCHAR(20) NOT NULL COMMENT '级别',
    award_date DATE NOT NULL,
    PRIMARY KEY (id),
    KEY idx_recipient_id (recipient_id),
    KEY idx_award_type (award_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='教研/科研奖励表';

-- ========================================
-- 4. 人事与档案模块
-- ========================================

-- 人事详细信息表
CREATE TABLE IF NOT EXISTS hr_personnel (
    id BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
    teacher_id BIGINT NOT NULL COMMENT '关联教师表',
    hire_date DATE NOT NULL COMMENT '入职日期',
    first_contract_end DATE COMMENT '首聘期日期 (新入职必填)',
    regularization_date DATE COMMENT '转正日期 (新入职必填)',
    intro_level VARCHAR(50) COMMENT '引进层次',
    special_level VARCHAR(50) COMMENT '特聘层次',
    special_contract_date DATE COMMENT '特聘合同日期',
    special_contract_file VARCHAR(255) COMMENT '特聘合同上传路径',
    religion VARCHAR(50) COMMENT '宗教信仰',
    research_field VARCHAR(100) COMMENT '研究领域',
    PRIMARY KEY (id),
    UNIQUE KEY uk_teacher_id (teacher_id),
    CONSTRAINT fk_personnel_teacher FOREIGN KEY (teacher_id) REFERENCES base_teacher(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='人事详细信息表';

-- 学习经历表
CREATE TABLE IF NOT EXISTS hr_education_exp (
    id BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
    teacher_id BIGINT NOT NULL COMMENT '关联教师表',
    school_name VARCHAR(100) NOT NULL COMMENT '院校名称',
    degree VARCHAR(20) NOT NULL COMMENT '学位 (大专/本科/硕士/博士)',
    major VARCHAR(50) NOT NULL COMMENT '专业',
    start_date DATE NOT NULL COMMENT '起始时间',
    end_date DATE NOT NULL COMMENT '结束时间',
    grad_cert_path VARCHAR(255) COMMENT '毕业证书扫描件路径',
    deg_cert_path VARCHAR(255) COMMENT '学位证书扫描件路径',
    PRIMARY KEY (id),
    KEY idx_teacher_id (teacher_id),
    CONSTRAINT fk_edu_teacher FOREIGN KEY (teacher_id) REFERENCES base_teacher(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='学习经历表';

-- 工作/兼职经历表
CREATE TABLE IF NOT EXISTS hr_work_exp (
    id BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
    teacher_id BIGINT NOT NULL COMMENT '关联教师表',
    exp_type ENUM('SOCIAL', 'PART_TIME') NOT NULL COMMENT '类型 (社会兼职/个人兼职)',
    company_name VARCHAR(100) NOT NULL COMMENT '单位名称/创办公司名称',
    position VARCHAR(50) COMMENT '职位',
    is_legal_rep TINYINT DEFAULT 0 COMMENT '是否法人 (创业情况用)',
    reg_date DATE COMMENT '成立日期 (创业情况用)',
    start_date DATE NOT NULL COMMENT '开始时间',
    end_date DATE COMMENT '结束时间',
    PRIMARY KEY (id),
    KEY idx_teacher_id (teacher_id),
    CONSTRAINT fk_work_teacher FOREIGN KEY (teacher_id) REFERENCES base_teacher(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='工作/兼职经历表';

-- 家庭成员/子女信息表
CREATE TABLE IF NOT EXISTS hr_family (
    id BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
    teacher_id BIGINT NOT NULL COMMENT '关联教师表',
    relation VARCHAR(20) NOT NULL COMMENT '关系 (子女/配偶)',
    name VARCHAR(50) NOT NULL COMMENT '姓名',
    birth_date DATE NOT NULL COMMENT '出生日期',
    school_info VARCHAR(100) COMMENT '上学情况/幼儿园信息',
    fee_status VARCHAR(50) COMMENT '费用相关情况',
    PRIMARY KEY (id),
    KEY idx_teacher_id (teacher_id),
    CONSTRAINT fk_family_teacher FOREIGN KEY (teacher_id) REFERENCES base_teacher(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='家庭成员/子女信息表';

-- 年度考核结果表
CREATE TABLE IF NOT EXISTS hr_assessment (
    id BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
    teacher_id BIGINT NOT NULL COMMENT '关联教师表',
    year INT NOT NULL COMMENT '考核年份',
    result VARCHAR(20) NOT NULL COMMENT '考核结果 (优秀/合格/不合格)',
    type VARCHAR(20) NOT NULL COMMENT '考核类型 (事业单位考核)',
    PRIMARY KEY (id),
    UNIQUE KEY uk_teacher_year (teacher_id, year),
    KEY idx_year (year),
    CONSTRAINT fk_assessment_teacher FOREIGN KEY (teacher_id) REFERENCES base_teacher(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='年度考核结果表';

-- 学院文件制度表
CREATE TABLE IF NOT EXISTS sys_document (
    id BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键',
    doc_number VARCHAR(50) NOT NULL COMMENT '文号 (如: 院字[2023]01号)',
    doc_name VARCHAR(100) NOT NULL COMMENT '文件名称',
    doc_type VARCHAR(20) NOT NULL COMMENT '制度类型 (党字/院字/学字)',
    issue_date DATE NOT NULL COMMENT '出台日期',
    status VARCHAR(20) NOT NULL COMMENT '废改立情况 (有效/废止/修订)',
    related_doc VARCHAR(255) COMMENT '关联文件',
    interpreter VARCHAR(50) COMMENT '解释权部门/人员',
    PRIMARY KEY (id),
    UNIQUE KEY uk_doc_number (doc_number),
    KEY idx_doc_type (doc_type),
    KEY idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='学院文件制度表';

-- ========================================
-- 初始化数据
-- ========================================

-- 插入默认管理员账号
INSERT INTO sys_user (username, password, role, status) VALUES 
('admin', MD5('admin123'), 'ADMIN', 1);

-- 插入示例教师用户
INSERT INTO sys_user (username, password, role, status) VALUES 
('T2023001', MD5('123456'), 'TEACHER', 1),
('T2023002', MD5('123456'), 'TEACHER', 1);

-- 插入示例教师扩展信息
INSERT INTO base_teacher (user_id, teacher_no, name, title, department) VALUES 
(2, 'T2023001', '张教授', '教授', '计算机科学'),
(3, 'T2023002', '李讲师', '讲师', '软件工程');

-- 插入示例学生用户
INSERT INTO sys_user (username, password, role, status) VALUES 
('S2023001', MD5('123456'), 'STUDENT', 1),
('S2023002', MD5('123456'), 'STUDENT', 1);

-- 插入示例学生扩展信息
INSERT INTO base_student (user_id, student_no, name, class_name, department, grade) VALUES 
(4, 'S2023001', '王同学', '软件2101', '软件工程', '2021'),
(5, 'S2023002', '赵同学', '计算机2101', '计算机科学', '2021');
