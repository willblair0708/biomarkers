## ---------------------------------------------------------------------------------------------------------------------------------------------------------------------
library(tidyverse)
library(grid)
library(broom)
library(ggpubr)


## ---------------------------------------------------------------------------------------------------------------------------------------------------------------------
iMicroglia <- read_csv(file = "Analysis_iMicroglia_qPCR_wb/LRRK2_GENOTYPED_LINES_batches1to6.csv")

iMicroglia$Experiment <- factor(iMicroglia$Experiment)
iMicroglia$Line <- factor(iMicroglia$Line)
iMicroglia$Genotype <- factor(iMicroglia$Genotype)
iMicroglia$Treatment <- factor(iMicroglia$Treatment)
iMicroglia$Treatment <- iMicroglia$Treatment %>% fct_recode(DMSO="DMSO", LLOME="LysInh")
iMicroglia$Group <- paste(iMicroglia$Genotype, iMicroglia$Treatment, sep="-")

# mRNA and protein have different things, make two tibbles in tall format
## mRNA
iMicroglia.mRNA <- iMicroglia %>% select("Experiment", "Line","Genotype","Treatment","Replicate","Group",ends_with("mRNA")) %>% gather(RNA, expression, AIF1_mRNA, LRRK2_mRNA, TMEM119_mRNA, P2RY12_mRNA)

iMicroglia.mRNA$RNA <- iMicroglia.mRNA$RNA %>% fct_recode(AIF1="AIF1_mRNA", LRRK2="LRRK2_mRNA", TMEM119="TMEM119_mRNA", P2RY12="P2RY12_mRNA")

## protein
iMicroglia.protein <- iMicroglia %>% select("Experiment", "Line","Genotype","Treatment","Replicate","Group",ends_with("protein")) %>% gather(protein, expression, Iba1_protein, LRRK2_protein, pRAB10_protein, pp38_protein, pNFKB_protein, pS935LRRK2_protein)

iMicroglia.protein$protein <- iMicroglia.protein$protein %>% fct_recode(IBA1 = "Iba1_protein", LRRK2="LRRK2_protein", pRAB10="pRAB10_protein", pP38="pp38_protein", pNFKB="pNFKB_protein", pS935LRRK2="pS935LRRK2_protein")


## ---------------------------------------------------------------------------------------------------------------------------------------------------------------------
iMicroglia.mRNA.mean <- iMicroglia.mRNA %>% group_by(Experiment, RNA) %>% mutate(rel.expression = expression/mean(expression, na.rm=T))

iMicroglia.protein.mean <- iMicroglia.protein %>% group_by(Experiment, protein) %>% mutate(rel.expression = expression/mean(expression, na.rm=T))


## ---------------------------------------------------------------------------------------------------------------------------------------------------------------------
iMicroglia.mRNA.mean %>%
  ggplot(aes(x=Group, y=rel.expression, fill=Treatment)) +
  geom_boxplot(outlier.size = 0) +
  scale_fill_manual(values = c("white","lightgrey")) +
  geom_jitter(aes(color=Line), width=0.1, size=2, shape=1) +
  theme_classic() +
  labs(x = "Genotype-Treatment", y = "relative mRNA expression/PPID") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  facet_wrap(RNA~., scales="free")


## ---------------------------------------------------------------------------------------------------------------------------------------------------------------------
iMicroglia.protein.mean %>%
  ggplot(aes(x=Group, y=rel.expression, fill=Treatment)) +
  geom_boxplot(outlier.size = 0) +
  scale_fill_manual(values = c("white","lightgrey")) +
  geom_jitter(aes(color=Line), width=0.1, size=2, shape=1) +
  theme_classic() +
  labs(x = "Genotype-Treatment", y = "relative protein expression") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  facet_wrap(protein~., scales="free")


## ---------------------------------------------------------------------------------------------------------------------------------------------------------------------
models.RNA <-iMicroglia.mRNA.mean %>% group_by(RNA) %>% do(P = summary(aov(rel.expression ~ Genotype*Treatment, data = .))[[1]][["Pr(>F)"]][1:3] )
models.RNA$P <-lapply(models.RNA$P, setNames, c("P.Genotype","P.Treatment","P.Interaction"))
models.RNA <-models.RNA %>% { bind_cols(select(., RNA), bind_rows(!!!.$P)) }
models.RNA %>% print(n = Inf)


## ---------------------------------------------------------------------------------------------------------------------------------------------------------------------
models.protein <- iMicroglia.protein.mean %>% group_by(protein) %>% do(P = summary(aov(rel.expression ~ Genotype * Treatment, data=.))[[1]][["Pr(>F)"]][1:3] )
models.protein$P <-lapply(models.protein$P, setNames, c("P.Genotype","P.Treatment","P.Interaction"))
models.protein <-models.protein %>% { bind_cols(select(., protein), bind_rows(!!!.$P)) }
models.protein %>% print(n = Inf)


## ---------------------------------------------------------------------------------------------------------------------------------------------------------------------
iMicroglia.mRNA.mean %>% filter(RNA == "LRRK2") %>%
  ggplot(aes(x=Group, y=rel.expression, fill=Treatment)) +
  geom_boxplot(outlier.size = 0) +
  scale_fill_manual(values = c("white","lightgrey")) +
  geom_jitter(aes(color=Line), width=0.1, size=4, shape=1, stroke = 2) +
  ylim(0, 1.85) +
  theme_classic() +
  labs(x = "Genotype-Treatment", y = "Relative LRRK2/PPID mRNA Expression") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1), aspect.ratio = 1.2)


## ---------------------------------------------------------------------------------------------------------------------------------------------------------------------
iMicroglia.mRNA.mean %>% filter(RNA == "AIF1") %>%
  ggplot(aes(x=Group, y=rel.expression, fill=Treatment)) +
  geom_boxplot(outlier.size = 0) +
  scale_fill_manual(values = c("white","lightgrey")) +
  geom_jitter(aes(color=Line), width=0.1, size=4, shape=1, stroke = 2) +
  ylim(0, 1.85) +
  theme_classic() +
  labs(x = "Genotype-Treatment", y = "Relative AIF1/PPID mRNA Expression") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1), aspect.ratio = 1.2)


## ---------------------------------------------------------------------------------------------------------------------------------------------------------------------
iMicroglia.mRNA.mean %>% filter(RNA == "P2RY12") %>%
  ggplot(aes(x=Group, y=rel.expression, fill=Treatment)) +
  geom_boxplot(outlier.size = 0) +
  scale_fill_manual(values = c("white","lightgrey")) +
  geom_jitter(aes(color=Line), width=0.1, size=4, shape=1, stroke = 2) +
  ylim(0, 1.85) +
  theme_classic() +
  labs(x = "Genotype-Treatment", y = "Relative P2RY12/PPID mRNA Expression") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1), aspect.ratio = 1.2)


## ---------------------------------------------------------------------------------------------------------------------------------------------------------------------
iMicroglia.mRNA.mean %>% filter(RNA == "TMEM119") %>%
  ggplot(aes(x=Group, y=rel.expression, fill=Treatment)) +
  geom_boxplot(outlier.size = 0) +
  scale_fill_manual(values = c("white","lightgrey")) +
  geom_jitter(aes(color=Line), width=0.1, size=4, shape=1, stroke = 2) +
  ylim(0, 1.85) +
  theme_classic() +
  labs(x = "Genotype-Treatment", y = "Relative TMEM119/PPID mRNA Expression") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1), aspect.ratio = 1.2)


## ---------------------------------------------------------------------------------------------------------------------------------------------------------------------
iMicroglia.protein.mean %>% filter(protein == "LRRK2") %>%
  ggplot(aes(x=Group, y=rel.expression, fill=Treatment)) +
  geom_boxplot(outlier.size = 0) +
  scale_fill_manual(values = c("white","lightgrey")) +
  geom_jitter(aes(color=Line), width=0.1, size=4, shape=1, stroke = 2) +
  ylim(0, 2.2) +
  theme_classic() +
  labs(x = "Genotype-Treatment", y = "Relative LRRK2/Cyclophilin B Protein Expression") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1), aspect.ratio = 1.2)


## ---------------------------------------------------------------------------------------------------------------------------------------------------------------------
iMicroglia.protein.mean %>% filter(protein == "pRAB10") %>%
  ggplot(aes(x=Group, y=rel.expression, fill=Treatment)) +
  geom_boxplot(outlier.size = 0) +
  scale_fill_manual(values = c("white","lightgrey")) +
  geom_jitter(aes(color=Line), width=0.1, size=4, shape=1, stroke = 2) +
  ylim(0, 2.2) +
  theme_classic() +
  labs(x = "Genotype-Treatment", y = "Relative pRab10/Rab10 Protein Expression") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1), aspect.ratio = 1.2)


## ---------------------------------------------------------------------------------------------------------------------------------------------------------------------
iMicroglia.protein.mean %>% filter(protein == "pS935LRRK2") %>%
  ggplot(aes(x=Group, y=rel.expression, fill=Treatment)) +
  geom_boxplot(outlier.size = 0) +
  scale_fill_manual(values = c("white","lightgrey")) +
  geom_jitter(aes(color=Line), width=0.1, size=4, shape=1, stroke = 2) +
  ylim(0, 1.7) +
  theme_classic() +
  labs(x = "Genotype-Treatment", y = "Relative pS935-LRRK2/LRRK2 Protein Expression") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1), aspect.ratio = 1.2)


## ---------------------------------------------------------------------------------------------------------------------------------------------------------------------
iMicroglia.protein.mean %>% filter(protein == "IBA1") %>%
  ggplot(aes(x=Group, y=rel.expression, fill=Treatment)) +
  geom_boxplot(outlier.size = 0) +
  scale_fill_manual(values = c("white","lightgrey")) +
  geom_jitter(aes(color=Line), width=0.1, size=4, shape=1, stroke = 2) +
  ylim(0, 1.9) +
  theme_classic() +
  labs(x = "Genotype-Treatment", y = "Relative Iba1/Cyclophilin B Protein Expression") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1), aspect.ratio = 1.2)


## ---------------------------------------------------------------------------------------------------------------------------------------------------------------------
iMicroglia.protein.mean %>% filter(protein == "pP38") %>%
  ggplot(aes(x=Group, y=rel.expression, fill=Treatment)) +
  geom_boxplot(outlier.size = 0) +
  scale_fill_manual(values = c("white","lightgrey")) +
  geom_jitter(aes(color=Line), width=0.1, size=4, shape=1, stroke = 2) +
  ylim(0, 2.2) +
  theme_classic() +
  labs(x = "Genotype-Treatment", y = "Relative pP38/P38 Protein Expression") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1), aspect.ratio = 1.2)


## ---------------------------------------------------------------------------------------------------------------------------------------------------------------------
iMicroglia.protein.mean %>% filter(protein == "pNFKB") %>%
  ggplot(aes(x=Group, y=rel.expression, fill=Treatment)) +
  geom_boxplot(outlier.size = 0) +
  scale_fill_manual(values = c("white","lightgrey")) +
  geom_jitter(aes(color=Line), width=0.1, size=4, shape=1, stroke = 2) +
  ylim(0, 2.2) +
  theme_classic() +
  labs(x = "Genotype-Treatment", y = "Relative pNFKb/NFKb Protein Expression") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1), aspect.ratio = 1.2)

