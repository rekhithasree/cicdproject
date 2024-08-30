from django.shortcuts import render, redirect
from .forms import UserInfoForm

def user_info_view(request):
    if request.method == 'POST':
        form = UserInfoForm(request.POST)
        if form.is_valid():
            form.save()
            return redirect('success')
    else:
        form = UserInfoForm()
    return render(request, 'user_info.html', {'form': form})

def success_view(request):
    return render(request, 'success.html')
