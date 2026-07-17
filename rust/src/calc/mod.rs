// 计算核心：词法分析 -> 语法分析 -> 求值
// 函数式风格：纯函数 + 不可变 AST，避免全局可变状态
pub mod ast;
pub mod eval;
pub mod parser;
pub mod token;

/// 顶层求值入口：字符串 -> f64
pub fn evaluate(input: &str) -> Result<f64, String> {
    let tokens = token::tokenize(input)?;
    let ast = parser::parse(&tokens)?;
    eval::eval(&ast)
}
