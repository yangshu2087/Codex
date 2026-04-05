# Awesome DESIGN.md 甄别与落地结论

## 来源

- 仓库：`VoltAgent/awesome-design-md`
- 参考文档：
  - README（DESIGN.md 概念与 9 段结构）
  - 多个样例 `DESIGN.md`（如 Vercel / Notion）

## 我们采纳的内容（Adopt）

1. **DESIGN.md 作为项目级 UI 合约**
   - 与 `AGENTS.md` 分工：
     - `AGENTS.md` 管流程与工程行为
     - `DESIGN.md` 管视觉与交互风格
2. **结构化设计描述（9 段）**
   - 视觉主题
   - 颜色角色
   - 排版规则
   - 组件样式
   - 布局原则
   - 层级与阴影
   - Do/Don't
   - 响应式策略
   - Agent Prompt Guide
3. **状态与响应式作为硬约束**
   - loading / empty / error / hover / focus-visible / disabled
   - 375 / 768 / 1024 / 1440 验证
4. **浏览器验证优先于“仅代码通过”**

## 我们不直接采纳的内容（Reject / Adapt）

1. **不直接拷贝第三方品牌视觉参数**
   - 不把外部品牌的完整颜色、字体、阴影体系原样搬进生产。
2. **不以“像某网站”替代产品需求**
   - 外部样例只作灵感，不替代本项目信息架构和业务目标。
3. **不把 DESIGN.md 当静态文档**
   - 必须在项目演进中与真实组件和 token 同步更新。

## 团队统一策略

- 每个仓库有且仅有一个仓库级 `DESIGN.md`。
- 存在 Web 子应用（`web/` 或 `apps/web/`）时，子应用也维护自己的 `DESIGN.md` 与 `docs/ui-acceptance-checklist.md`。
- `AGENTS.md` 与 `.cursor/rules/agent-workflow.mdc` 明确要求前端任务先读 `DESIGN.md`。

## 自动化落地

使用脚本：

```bash
python3 /Users/yangshu/Codex/scripts/rollout-design-md.py
```

该脚本会在已配置项目中自动补齐：
- `DESIGN.md`
- `AGENTS.md` 的 DESIGN.md workflow 段
- `.cursor/rules/agent-workflow.mdc` 的 DESIGN.md 约束
- 对 Web 子应用补齐 `DESIGN.md` 与 `docs/ui-acceptance-checklist.md`

## 后续维护建议

- 新项目初始化后第一天就落 `DESIGN.md`，避免后补导致风格漂移。
- 每次 UI 大改后同时更新：
  - `DESIGN.md`
  - 相关组件 token
  - `docs/ui-acceptance-checklist.md`（如新增验收项）
- PR 模板里要求提交者说明：是否遵循 DESIGN.md，是否完成多断点浏览器验证。
