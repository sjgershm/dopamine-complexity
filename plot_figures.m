function plot_figures(fig,tbl)

    % Generate results figures.
    % To produce the main results figure, use plot_figures('behavioral_results',tbl) and plot_figures('neural_results',tbl).
    %
    % USAGE: plot_figures(fig,[tbl])
    %
    % INPUTS:
    %   fig - figure name
    %   tbl (optional) - data table
    %
    % Sam Gershman, Nov 2024

    C = colormap('linspecer');

    if nargin < 2
        tbl = readtable('Lak20_dopamine_data.csv');
    end

    switch fig

        case 'behavioral_results'

            subplot(1,3,1);
            plot_figures('RC_curve',tbl);
            mytitle('A','Left','FontSize',30,'FontWeight','Bold');
            subplot(1,3,2);
            plot_figures('bias_hist',tbl);
            mytitle('B','Left','FontSize',30,'FontWeight','Bold');
            subplot(1,3,3);
            plot_figures('choice_prob',tbl);
            mytitle('C','Left','FontSize',30,'FontWeight','Bold');

            set(gcf,'Position',[200 200 1500 400])

        case 'neural_results'

            subplot(1,3,1);
            plot_figures('coefficients',tbl);
            mytitle('A','Left','FontSize',30,'FontWeight','Bold');
            subplot(1,3,2);
            plot_figures('residual',tbl);
            mytitle('B','Left','FontSize',30,'FontWeight','Bold');
            subplot(1,3,3);
            plot_figures('coeff_invtemp',tbl);
            mytitle('C','Left','FontSize',30,'FontWeight','Bold');

            set(gcf,'Position',[200 200 1500 400])
        
        case 'RC_curve'

            sessions = unique(tbl.session);

            for i = 1:length(sessions)
                ix = tbl.session==sessions(i);
                v(i,1) = mean(tbl.outcome(ix));
                r(i,1) = mean(tbl.cost(ix));
            end

            u = unique(tbl.stimulus);
            for i=1:length(u)
                p(i) = mean(tbl.stimulus==u(i));
            end

            Q = [1.2 0; 1.2 0; 1.2 0; 1.2 0; 0.6 1.2; 0 2.4; 0 2.4; 0 2.4; 0 2.4];
            b = linspace(0.1,15,50);
            [R,V] = blahut_arimoto(p,Q,b);
            plot(R,V,'-','LineWidth',4,'Color',C(1,:))
            hold on;
            plot(r,v,'+','LineWidth',4,'MarkerSize',10,'Color',C(60,:))

            set(gca,'FontSize',25,'XLim',[0 0.5])
            ylabel('Average reward','FontSize',25)
            xlabel('Policy complexity','FontSize',25)

            vq = interp1(R,V,r);
            deviation = 100*(vq-v)./vq;
            median(deviation)    % inefficiency


        case 'bias_hist'

            sessions = unique(tbl.session);
            for s = 1:length(sessions); b(s) = mean(tbl.marginal(tbl.session==sessions(s))); end
            hist(b);
            set(gca,'XLim',[0 1],'FontSize',25)
            ylabel('Frequency','FontSize',25)
            xlabel('Bias','FontSize',25)

        case 'residual'

            model = fitlm(tbl,'outcomeresponse ~ outcome + action_value + cost');
            resid = model.Residuals.Raw + model.Coefficients.Estimate(end)*tbl.cost;
            q = linspace(-0.6,1.5,6);
            [m,se,~,q] = interval_stats(resid,tbl.cost,q);
            errorbar(q,m,se,'LineWidth',4);
            set(gca,'FontSize',25,'XLim',[min(q)-0.1 max(q)+0.1])
            xlabel('Policy cost','FontSize',25)
            ylabel('Partial residual','FontSize',25)

        case 'choice_prob'

            action = tbl.action;
            action(action==-1) = 0;
            [~, P] = fit_invtemp(tbl);
            q = unique(tbl.stimulus);
            q(1) = []; q(end) = [];
            for i = 1:2
                if i == 1
                    ix = tbl.marginal < 0.5;
                else
                    ix = tbl.marginal > 0.5;
                end
                for s = 1:length(q)
                    ix2 = ix & tbl.stimulus==q(s);
                    m(s,i) = mean(action(ix2));
                    se(s,i) = std(action(ix2))./sqrt(sum((ix2)));
                    p(s,i) = mean(P(ix2));
                end
            end

            colors = [1 50];

            for j = 1:2
                h(j) = plot(q,p(:,j),'LineWidth',4,'Color',C(colors(j),:)); hold on;
                errorbar(q,m(:,j),se(:,j),'o','LineWidth',4,'Color',C(colors(j),:));
            end
            legend(h,{'Left bias' 'Right bias'},'FontSize',25,'Box','Off','Location','best');
            set(gca,'FontSize',25,'XLim',[min(q)-0.1 max(q)+0.1],'XTick',[-0.5 -0.25 0 0.25 0.5])
            xlabel('Contrast','FontSize',25)
            ylabel('P(right)','FontSize',25)

        case 'coefficients'

            model = fitlm(tbl,'outcomeresponse ~ outcome + action_value + cost');
            estimates = model.Coefficients.Estimate(2:end);
            se = model.Coefficients.SE(2:end);
            errorbar(estimates,1:3,se,'.k','horizontal','MarkerSize',10,'LineWidth',4,'MarkerFaceColor','w');
            set(gca,'YTick',1:3,'YTickLabel',{'Outcome' 'Action value' 'Policy cost'},'FontSize',25,'YLim',[0.5 3.5])
            xlabel('Coefficient','FontSize',25);
            hold on;
            plot([0 0],get(gca,'YLim'),'--k','LineWidth',4)


        case 'coeff_invtemp'

            B = fit_invtemp(tbl);

            sessions = unique(tbl.session);
            for i = 1:length(sessions)
                ix = tbl.session == sessions(i);
                model = fitlm(tbl(ix,:),'outcomeresponse ~ outcome + action_value + cost');
                coeff(i) = model.Coefficients.Estimate(2);
            end

            [r,p] = corr(coeff',B')

            plot(coeff,B,'+k','LineWidth',4,'MarkerSize',10);
            h = lsline; h.LineWidth = 4;

            set(gca,'FontSize',25)
            ylabel('Inverse temperature','FontSize',25)
            xlabel('Neural outcome coefficient','FontSize',25)

    end

    fontname('Baskerville')