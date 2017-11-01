function [ ti,td,tnp,ti_tst,td_tst,tnp_tst,ni,no,network ] = process_inputs(...
 data,network,train_per,normF)
% Process training and tesinng data

[np,nd] = size(data);   % Number of inputs + outputs
no = network(end);      % Number of outputs
ni = nd - no;           % Number of inputs
ti = data(:, 1:ni);     % Input data
td = data(:,ni+1:nd);   % Output data
network = [ni network]; % Add inputs to network

% normalize
if(normF > 0)
    for i = 1:ni
        ti(:,i) = 2 * (ti(:,i) - min(ti(:,i)))/(max(ti(:,i)) - min(ti(:,i))) - 1;
    end
    for i = 1:no
        td(:,i) = 2 * (td(:,i) - min(td(:,i)))/(max(td(:,i)) - min(td(:,i))) - 1;
    end
end

if(train_per < 1.0)
    tnp = round(np*train_per);
    ti_tst = ti(tnp+1:end,:);  ti = ti(1:tnp,:);
    td_tst = td(tnp+1:end,1:no);    td = td(1:tnp,1:no);
else
    ti_tst = ti;
    td_tst = td;
end

tnp=size(ti,1);   tnp_tst = size(ti_tst,1);

end

