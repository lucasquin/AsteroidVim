local lspconfig_status_ok, lspconfig = pcall(require, "lspconfig")
if not lspconfig_status_ok then
	return
end

local cmp_nvim_lsp_status_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if not cmp_nvim_lsp_status_ok then
	return
end

local typescript_status_ok, typescript = pcall(require, "typescript")
if not typescript_status_ok then
	return
end

local function toSnakeCase(str)
	return string.gsub(str, "%s*[- ]%s*", "_")
end

local on_attach = function(client, bufnr)
	if client.name == "omnisharp" then
		local tokenModifiers = client.server_capabilities.semanticTokensProvider.legend.tokenModifiers
		for i, v in ipairs(tokenModifiers) do
			tokenModifiers[i] = toSnakeCase(v)
		end
		local tokenTypes = client.server_capabilities.semanticTokensProvider.legend.tokenTypes
		for i, v in ipairs(tokenTypes) do
			tokenTypes[i] = toSnakeCase(v)
		end
	end

	local opts = { noremap = true, silent = true, buffer = bufnr }
	vim.keymap.set("n", "<F12>", "<cmd>Lspsaga peek_definition<CR>", opts)
	vim.keymap.set("n", "<C-F12>", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
	vim.keymap.set("n", "<S-F12>", "<cmd>Lspsaga hover_doc<CR>", opts)
	vim.keymap.set("n", "<C-S-F12>", "<cmd>Lspsaga finder<CR>", opts)
	vim.keymap.set("n", "<leader>ca", "<cmd>Lspsaga code_action<CR>", opts)
	vim.keymap.set("n", "<leader>rn", "<cmd>Lspsaga rename<CR>", opts)
	vim.keymap.set("n", "<leader>fm", "<cmd>lua vim.lsp.buf.format({ async = true })<CR>", {})
end

local signs = { Error = " ", Warn = " ", Hint = "ﴞ ", Info = " " }
for type, icon in pairs(signs) do
	local hl = "DiagnosticSign" .. type
	vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = cmp_nvim_lsp.default_capabilities(capabilities)

lspconfig["lua_ls"].setup({
	capabilities = capabilities,
	on_attach = on_attach,
	settings = {
		Lua = {
			diagnostics = {
				globals = { "vim" },
			},
			workspace = {
				library = {
					[vim.fn.expand("$VIMRUNTIME/lua")] = true,
					[vim.fn.stdpath("config") .. "/lua"] = true,
				},
			},
		},
	},
	filetypes = { "lua" },
})

lspconfig["html"].setup({
	capabilities = capabilities,
	on_attach = on_attach,
})

lspconfig["cssls"].setup({
	capabilities = capabilities,
	on_attach = on_attach,
})

typescript.setup({
	server = {
		capabilities = capabilities,
		on_attach = on_attach,
	},
})

lspconfig["jsonls"].setup({
	capabilities = capabilities,
	on_attach = on_attach,
	filetypes = { "json" },
})

lspconfig["angularls"].setup({
	capabilities = capabilities,
	on_attach = on_attach,
	filetypes = { "html" },
})

lspconfig["clangd"].setup({
	capabilities = capabilities,
	on_attach = on_attach,
})

lspconfig["omnisharp"].setup({
	analyze_open_documents_only = true,
	capabilities = capabilities,
	enable_editorconfig_support = false,
	enable_import_completion = false,
	enable_ms_build_load_projects_on_demand = false,
	enable_roslyn_analyzers = false,
	organize_imports_on_format = false,
	sdk_include_prereleases = true,
	filetypes = { "cs", "vb" },
	on_attach = on_attach,
	flags = {
		debounce_text_changes = 150,
	},
})