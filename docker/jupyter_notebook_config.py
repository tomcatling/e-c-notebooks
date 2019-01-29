c.NotebookApp.password = 'sha1:3fe49948c4c4:e29469efb8c9ff0a881387fec9717361f4393fda'
c.NotebookApp.password_required = True
c.NotebookApp.allow_origin = '*'
c.NotebookApp.open_browser = False
c.NotebookApp.port = 8888
c.NotebookApp.allow_root = True
def scrub_output_pre_save(model, **kwargs):
    """scrub output before saving notebooks"""
    # only run on notebooks
    if model['type'] != 'notebook':
        return
    # only run on nbformat v4
    if model['content']['nbformat'] != 4:
        return

    for cell in model['content']['cells']:
        if cell['cell_type'] != 'code':
            continue
        cell['outputs'] = []
        cell['execution_count'] = None
        if 'collapsed' in cell['metadata']:
            cell['metadata'].pop('collapsed', 0)

c.FileContentsManager.pre_save_hook = scrub_output_pre_save
