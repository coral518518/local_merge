import os

ext_list = ['.html', '.js']
replacements = {
    '"/static/': '"/grok2api-main/static/',
    "'/static/": "'/grok2api-main/static/",
    '"/admin/': '"/grok2api-main/admin/',
    "'/admin/": "'/grok2api-main/admin/",
    '"/function/': '"/grok2api-main/function/',
    "'/function/": "'/grok2api-main/function/",
    '"/v1/': '"/grok2api-main/v1/',
    "'/v1/": "'/grok2api-main/v1/"
}

for root, _, files in os.walk('_public'):
    for f in files:
        if not any(f.endswith(ext) for ext in ext_list): continue
        path = os.path.join(root, f)
        try:
            with open(path, 'r', encoding='utf-8') as f_in: content = f_in.read()
            new_content = content
            for old, new in replacements.items(): new_content = new_content.replace(old, new)
            if new_content != content:
                with open(path, 'w', encoding='utf-8') as f_out: f_out.write(new_content)
                print('Updated', path)
        except Exception as e: print(path, e)

py_replacements = {
    'url="/admin/': 'url="/grok2api-main/admin/',
    'url="/function/': 'url="/grok2api-main/function/',
    'url="/static/': 'url="/grok2api-main/static/'
}
for root, _, files in os.walk('app/api'):
    for f in files:
        if not f.endswith('.py'): continue
        path = os.path.join(root, f)
        try:
            with open(path, 'r', encoding='utf-8') as f_in: content = f_in.read()
            new_content = content
            for old, new in py_replacements.items(): new_content = new_content.replace(old, new)
            if new_content != content:
                with open(path, 'w', encoding='utf-8') as f_out: f_out.write(new_content)
                print('Updated', path)
        except Exception as e: print(path, e)

with open('main.py', 'r', encoding='utf-8') as f_in: content = f_in.read()
new_content = content.replace('url="/static/', 'url="/grok2api-main/static/')
if new_content != content:
    with open('main.py', 'w', encoding='utf-8') as f_out: f_out.write(new_content)
    print('Updated main.py')
