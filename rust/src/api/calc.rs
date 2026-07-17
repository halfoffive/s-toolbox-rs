// 计算器对 Flutter 暴露的入口
// 仅做薄封装：把字符串表达式交给 calc 模块求值
use crate::calc::evaluate as calc_evaluate;

/// 求值入口：解析并计算中缀表达式字符串
///
/// 成功返回 f64；失败返回中文错误描述字符串
/// （跨 FFI 边界用 String 最简单，避免错误类型序列化复杂度）
#[flutter_rust_bridge::frb(sync)]
pub fn evaluate(expression: String) -> Result<f64, String> {
    calc_evaluate(&expression)
}

/// 默认初始化（FRB 模板保留）
#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    flutter_rust_bridge::setup_default_user_utils();
}
